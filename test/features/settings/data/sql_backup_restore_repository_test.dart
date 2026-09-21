import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/crypto/key_manager.dart';
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/features/settings/data/repositories/sql_backup_restore_repository.dart';
import 'package:hananote/features/settings/domain/entities/backup_restore_payload.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class _MockKeyManager extends Mock implements KeyManager {}

class _MockTransaction extends Mock implements Transaction {}

class _RecordingDatabase extends SecureDatabase {
  _RecordingDatabase({this.conflictTable}) : super(_MockKeyManager());
  final String? conflictTable;
  final queryRows = <String, List<Map<String, Object?>>>{};
  final committed = <String>[];
  var transactionCalls = 0;

  @override
  Future<T> runInTransaction<T>(
      Future<T> Function(Transaction txn) action) async {
    transactionCalls++;
    final staged = <String>[];
    final txn = _MockTransaction();
    when(() => txn.query(any())).thenAnswer((call) async =>
        queryRows[call.positionalArguments.first as String] ?? []);
    when(() => txn.update(any(), any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 0);
    when(() => txn.insert(any(), any(),
            conflictAlgorithm: any(named: 'conflictAlgorithm')))
        .thenAnswer((call) async {
      final values = call.positionalArguments[1] as Map<String, Object?>;
      if (call.positionalArguments.first == conflictTable) {
        throw StateError('synthetic unique constraint');
      }
      if (values['id'] == 'drug-2')
        throw StateError('synthetic disk write failure');
      staged.add(values['id']! as String);
      return staged.length;
    });
    final result = await action(txn);
    committed.addAll(staged);
    return result;
  }
}

void main() {
  setUpAll(() => registerFallbackValue(ConflictAlgorithm.abort));
  test('test: a later SQL write failure leaves no earlier writes committed',
      () async {
    final database = _RecordingDatabase();
    final repository = SqlBackupRestoreRepository(database);
    final payload = BackupRestorePayload({
      'drugs': [
        {'id': 'drug-1', 'name': 'first'},
        {'id': 'drug-2', 'name': 'second'},
      ],
      'schedules': [],
      'medicationLogs': [],
      'drugInventory': [],
      'bloodTests': [],
      'journals': [],
      'measurements': [],
    });
    final result = await repository.restore(payload);
    expect(result.isLeft(), isTrue);
    expect(database.transactionCalls, 1);
    expect(database.committed, isEmpty);
  });
  for (final conflict in [
    ('journal_entries', 'journals', 'date'),
    ('drug_inventory', 'drugInventory', 'drug_id'),
  ]) {
    test('test: unique ${conflict.$3} conflict preserves unrelated local ID',
        () async {
      final database = _RecordingDatabase(conflictTable: conflict.$1);
      database.committed.add('local-unrelated-id');
      final repository = SqlBackupRestoreRepository(database);
      final tables = <String, List<Map<String, Object?>>>{
        'drugs': [],
        'schedules': [],
        'medicationLogs': [],
        'drugInventory': [],
        'bloodTests': [],
        'journals': [],
        'measurements': [],
      };
      tables[conflict.$2] = [
        {'id': 'backup-id', conflict.$3: 'same-unique-value'}
      ];
      final result = await repository.restore(BackupRestorePayload(tables));
      expect(result.isLeft(), isTrue);
      expect(database.committed, ['local-unrelated-id']);
      expect(database.transactionCalls, 1);
    });
  }
  test('test: export omits tombstones and orphaned medication children',
      () async {
    final database = _RecordingDatabase();
    database.queryRows.addAll({
      'drugs': [
        {'id': 'drug-live', 'is_deleted': 0},
        {'id': 'drug-deleted', 'is_deleted': 1},
      ],
      'medication_schedules': [
        {'id': 'schedule-live', 'drug_id': 'drug-live', 'is_deleted': 0},
        {'id': 'schedule-deleted', 'drug_id': 'drug-live', 'is_deleted': 1},
        {'id': 'schedule-orphan', 'drug_id': 'drug-deleted', 'is_deleted': 0},
      ],
      'medication_logs': [
        {
          'id': 'log-live',
          'schedule_id': 'schedule-live',
          'drug_id': 'drug-live',
          'is_deleted': 0
        },
        {
          'id': 'log-deleted',
          'schedule_id': 'schedule-live',
          'drug_id': 'drug-live',
          'is_deleted': 1
        },
        {
          'id': 'log-orphan',
          'schedule_id': 'schedule-deleted',
          'drug_id': 'drug-live',
          'is_deleted': 0
        },
      ],
      'drug_inventory': [
        {'id': 'inventory-live', 'drug_id': 'drug-live'},
        {'id': 'inventory-orphan', 'drug_id': 'drug-deleted'},
      ],
    });
    final result = await SqlBackupRestoreRepository(database).exportRecords();
    expect(result.isRight(), isTrue);
    final tables = result.getRight().toNullable()!.tables;
    expect(tables['drugs']!.map((row) => row['id']), ['drug-live']);
    expect(tables['schedules']!.map((row) => row['id']), ['schedule-live']);
    expect(tables['medicationLogs']!.map((row) => row['id']), ['log-live']);
    expect(
        tables['drugInventory']!.map((row) => row['id']), ['inventory-live']);
  });
}
