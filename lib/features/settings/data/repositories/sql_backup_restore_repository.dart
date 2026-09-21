import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/entities/backup_restore_payload.dart';
import 'package:hananote/features/settings/domain/repositories/backup_restore_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// SQLCipher implementation of the records backup boundary.
@LazySingleton(as: BackupRestoreRepository)
class SqlBackupRestoreRepository implements BackupRestoreRepository {
  /// Creates a repository using the app's open encrypted database.
  const SqlBackupRestoreRepository(this._database);

  final SecureDatabase _database;

  static const _tables = <String, String>{
    'drugs': 'drugs',
    'schedules': 'medication_schedules',
    'medicationLogs': 'medication_logs',
    'drugInventory': 'drug_inventory',
    'bloodTests': 'blood_test_reports',
    'journals': 'journal_entries',
    'measurements': 'measurements',
  };

  @override
  Future<Either<Failure, BackupRestorePayload>> exportRecords() async {
    try {
      final payload = await _database.runInTransaction((txn) async {
        final rows = <String, List<Map<String, Object?>>>{};
        for (final entry in _tables.entries) {
          rows[entry.key] = (await txn.query(entry.value))
              .map((row) => Map<String, Object?>.from(row))
              .toList();
        }
        for (final table in ['drugs', 'schedules', 'medicationLogs']) {
          rows[table]!.removeWhere((row) => row['is_deleted'] == 1);
        }
        final liveDrugIds = rows['drugs']!.map((row) => row['id']).toSet();
        rows['schedules']!.removeWhere(
          (row) => !liveDrugIds.contains(row['drug_id']),
        );
        final liveScheduleDrugIds = {
          for (final row in rows['schedules']!) row['id']: row['drug_id'],
        };
        rows['medicationLogs']!.removeWhere(
          (row) =>
              !liveDrugIds.contains(row['drug_id']) ||
              liveScheduleDrugIds[row['schedule_id']] != row['drug_id'],
        );
        rows['drugInventory']!.removeWhere(
          (row) => !liveDrugIds.contains(row['drug_id']),
        );
        final readings = await txn.query('hormone_readings');
        for (final report in rows['bloodTests']!) {
          report['readings'] = readings
              .where((reading) => reading['report_id'] == report['id'])
              .map((reading) => Map<String, Object?>.from(reading))
              .toList();
        }
        return BackupRestorePayload(rows);
      });
      return right(payload);
    } catch (_) {
      return left(
          const DatabaseFailure(message: 'Unable to read backup records.'));
    }
  }

  @override
  Future<Either<Failure, int>> restore(BackupRestorePayload payload) async {
    try {
      await _database.runInTransaction((txn) async {
        for (final entry in _tables.entries) {
          for (final row in payload.tables[entry.key]!) {
            final values = Map<String, Object?>.from(row);
            final readings = values.remove('readings');
            if (entry.key == 'bloodTests') {
              await txn.delete('hormone_readings',
                  where: 'report_id = ?', whereArgs: [values['id']]);
            }
            if (entry.key == 'drugs' ||
                entry.key == 'schedules' ||
                entry.key == 'medicationLogs') {
              values['dirty'] = 1;
              values['synced_at'] = null;
              values['is_deleted'] = 0;
              values['updated_at'] = DateTime.now().toUtc().toIso8601String();
            }
            final updated = await txn.update(entry.value, values,
                where: 'id = ?', whereArgs: [values['id']]);
            if (updated == 0) {
              await txn.insert(entry.value, values,
                  conflictAlgorithm: ConflictAlgorithm.abort);
            }
            if (readings is List<Map<String, Object?>>) {
              for (final reading in readings) {
                await txn.insert('hormone_readings', reading,
                    conflictAlgorithm: ConflictAlgorithm.abort);
              }
            }
          }
        }
      });
      return right(payload.recordCount);
    } catch (_) {
      return left(const DatabaseFailure(
          message: 'Backup restore failed; no records were changed.'));
    }
  }
}
