import 'dart:convert';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/backup/backup_vault_service.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/entities/backup_restore_payload.dart';
import 'package:hananote/features/settings/domain/repositories/backup_restore_repository.dart';
import 'package:injectable/injectable.dart';

/// Explicit file format selected by the import UI.
enum ImportBackupFormat {
  /// Current encrypted HanaNote vault.
  vault,

  /// Legacy plaintext records JSON selected by the user.
  legacyJson,
}

/// Validates a complete backup before asking SQLCipher to restore it.
@injectable
class ImportData {
  /// Creates the import use case.
  const ImportData(this._repository, this._vault);

  final BackupRestoreRepository _repository;
  final BackupVaultService _vault;

  /// Restores records from a vault or explicitly selected legacy JSON file.
  Future<Either<Failure, int>> call({
    required Uint8List backupBytes,
    required String password,
    required ImportBackupFormat format,
  }) async {
    try {
      if (backupBytes.length > BackupVaultService.maxVaultBytes) {
        throw const FormatException('Backup file is too large.');
      }
      final String json;
      if (format == ImportBackupFormat.vault) {
        if (!_vault.looksLikeVault(backupBytes)) {
          throw const FormatException('Invalid vault envelope.');
        }
        final result = await _vault.decryptJson(
          vaultBytes: backupBytes,
          password: password,
        );
        if (result.isLeft()) return result.fold(left, (_) => right(0));
        json = result.getOrElse((_) => '');
      } else {
        json = utf8.decode(backupBytes);
      }
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup root must be an object.');
      }
      return _repository.restore(_validate(decoded));
    } catch (_) {
      return left(const Failure.validation(
          message: 'Invalid backup format or records.'));
    }
  }

  static const _columns = <String, Set<String>>{
    'drugs': {
      'id',
      'name',
      'generic_name',
      'category',
      'administration_route',
      'default_dosage_unit',
      'is_active',
      'created_at',
      'notes',
      'dirty',
      'synced_at',
      'is_deleted',
      'updated_at'
    },
    'schedules': {
      'id',
      'drug_id',
      'dosage_amount',
      'dosage_unit',
      'frequency_type',
      'frequency_value',
      'administration_route',
      'schedule_times',
      'interval_days',
      'start_date',
      'end_date',
      'is_active',
      'notes',
      'dirty',
      'synced_at',
      'is_deleted',
      'updated_at'
    },
    'medicationLogs': {
      'id',
      'schedule_id',
      'drug_id',
      'timestamp',
      'dosage_amount',
      'dosage_unit',
      'administration_route',
      'status',
      'injection_site',
      'patch_site',
      'patch_count',
      'gel_pumps',
      'skin_reaction',
      'notes',
      'dirty',
      'synced_at',
      'is_deleted',
      'updated_at'
    },
    'drugInventory': {
      'id',
      'drug_id',
      'quantity',
      'unit',
      'purchase_date',
      'expiration_date',
      'batch_number',
      'notes',
      'updated_at'
    },
    'bloodTests': {
      'id',
      'test_date',
      'lab_name',
      'notes',
      'created_at',
      'readings'
    },
    'journals': {
      'id',
      'date',
      'content',
      'mood',
      'tags',
      'notes',
      'created_at',
      'updated_at'
    },
    'measurements': {
      'id',
      'date',
      'bust',
      'underbust',
      'waist',
      'hip',
      'thigh',
      'bicep',
      'shoulder',
      'neck',
      'weight',
      'notes',
      'created_at',
      'updated_at'
    },
  };
  static const _required = <String, Set<String>>{
    'drugs': {
      'id',
      'name',
      'generic_name',
      'category',
      'administration_route',
      'default_dosage_unit',
      'is_active',
      'created_at'
    },
    'schedules': {
      'id',
      'drug_id',
      'dosage_amount',
      'dosage_unit',
      'frequency_type',
      'frequency_value',
      'administration_route',
      'schedule_times',
      'start_date',
      'is_active'
    },
    'medicationLogs': {
      'id',
      'schedule_id',
      'drug_id',
      'timestamp',
      'dosage_amount',
      'dosage_unit',
      'administration_route',
      'status'
    },
    'drugInventory': {
      'id',
      'drug_id',
      'quantity',
      'unit',
      'purchase_date',
      'updated_at'
    },
    'bloodTests': {'id', 'test_date', 'created_at', 'readings'},
    'journals': {'id', 'date', 'content', 'mood', 'created_at'},
    'measurements': {'id', 'date', 'created_at'},
  };
  static const _dates = {
    'created_at',
    'updated_at',
    'start_date',
    'end_date',
    'timestamp',
    'purchase_date',
    'expiration_date',
    'test_date',
    'date'
  };
  static const _numbers = {
    'dosage_amount',
    'quantity',
    'value',
    'bust',
    'underbust',
    'waist',
    'hip',
    'thigh',
    'bicep',
    'shoulder',
    'neck',
    'weight'
  };
  static const _ints = {
    'is_active',
    'dirty',
    'is_deleted',
    'interval_days',
    'patch_count',
    'gel_pumps'
  };
  static const _enumValues = <String, Set<String>>{
    'category': {'estrogen', 'antiAndrogen', 'progestogen', 'auxiliary'},
    'dosage_unit': {'mg', 'mcg', 'ml', 'patch', 'pump'},
    'unit': {'mg', 'mcg', 'ml', 'patch', 'pump'},
    'administration_route': {
      'oral',
      'sublingual',
      'transdermalPatch',
      'transdermalGel',
      'intramuscularInjection',
      'subcutaneousInjection',
      'rectal'
    },
    'status': {'taken', 'skipped', 'late'},
    'injection_site': {'leftGlute', 'rightGlute', 'leftThigh', 'rightThigh'},
    'patch_site': {
      'lowerAbdomen',
      'upperAbdomen',
      'leftHip',
      'rightHip',
      'leftUpperArm',
      'rightUpperArm',
      'leftButtock',
      'rightButtock'
    },
    'skin_reaction': {'none', 'redness', 'itching', 'allergy'},
    'mood': {'veryBad', 'bad', 'neutral', 'good', 'veryGood'},
    'hormone_type': {
      'estradiol',
      'testosterone',
      'prolactin',
      'progesterone',
      'lh',
      'fsh',
      'shbg'
    },
  };

  BackupRestorePayload _validate(Map<String, dynamic> root) {
    if (root['format'] != 'hananote.records.v1' ||
        root['version'] != '1.0' ||
        root['exportDate'] is! String ||
        DateTime.tryParse(root['exportDate'] as String) == null) {
      throw const FormatException('Unsupported backup version or date.');
    }
    final allowedTop = {
      ..._columns.keys,
      'format',
      'version',
      'exportDate',
      'profile'
    };
    if (root.keys.any((key) => !allowedTop.contains(key))) {
      throw const FormatException('Unsupported backup collection.');
    }
    final tables = <String, List<Map<String, Object?>>>{};
    final ids = <String, Set<String>>{};
    for (final table in _columns.keys) {
      final raw = root[table];
      if (raw is! List)
        throw const FormatException('Missing backup collection.');
      final rows = <Map<String, Object?>>[];
      final seen = <String>{};
      for (final item in raw) {
        if (item is! Map<String, dynamic>)
          throw const FormatException('Invalid record.');
        final row = Map<String, Object?>.from(item);
        if (row.keys.any((key) => !_columns[table]!.contains(key)) ||
            _required[table]!
                .any((key) => !row.containsKey(key) || row[key] == null)) {
          throw const FormatException('Invalid record fields.');
        }
        final id = row['id'];
        if (id is! String || id.isEmpty || !seen.add(id)) {
          throw const FormatException('Invalid or duplicate record ID.');
        }
        for (final entry in row.entries) {
          final value = entry.value;
          if (value == null || entry.key == 'readings') continue;
          if (_dates.contains(entry.key)) {
            if (entry.key == 'updated_at' &&
                value == '' &&
                {'drugs', 'schedules', 'medicationLogs'}.contains(table)) {
              continue;
            }
            if (value is! String || DateTime.tryParse(value) == null)
              throw const FormatException('Invalid date.');
          } else if (_numbers.contains(entry.key)) {
            if (value is! num || !value.isFinite || value < 0)
              throw const FormatException('Invalid number.');
          } else if (_ints.contains(entry.key)) {
            if (value is! int || value < 0)
              throw const FormatException('Invalid integer.');
          } else if (value is! String) {
            throw const FormatException('Invalid field type.');
          }
          if ({'is_active', 'dirty', 'is_deleted'}.contains(entry.key) &&
              value != 0 &&
              value != 1) {
            throw const FormatException('Invalid boolean flag.');
          }
          if (entry.key == 'tags' && value is String) {
            final tags = jsonDecode(value);
            if (tags is! List || tags.any((tag) => tag is! String)) {
              throw const FormatException('Invalid journal tags.');
            }
          }
          final choices = _enumValues[entry.key];
          if (choices != null && !choices.contains(value))
            throw const FormatException('Invalid enum.');
        }
        if (table == 'bloodTests') _validateReadings(row);
        if (table == 'schedules') {
          final times = jsonDecode(row['schedule_times'] as String);
          if (times is! List)
            throw const FormatException('Invalid schedule times.');
          for (final time in times) {
            if (time is! Map<String, dynamic>)
              throw const FormatException('Invalid schedule time.');
            final hour = time['hour'];
            final minute = time['minute'];
            if (hour is! int ||
                minute is! int ||
                hour < 0 ||
                hour > 23 ||
                minute < 0 ||
                minute > 59) {
              throw const FormatException('Invalid schedule time.');
            }
          }
          final frequencyType = row['frequency_type'];
          final frequencyValue = row['frequency_value'];
          if (frequencyType != 'custom') {
            final amount = int.tryParse(frequencyValue as String);
            if (amount == null ||
                amount < 1 ||
                (frequencyType == 'weekly' && amount > 7)) {
              throw const FormatException('Invalid frequency value.');
            }
          }
          if (!{'daily', 'weekly', 'everyNDays', 'custom'}
              .contains(row['frequency_type']))
            throw const FormatException('Invalid frequency.');
        }
        rows.add(row);
      }
      tables[table] = rows;
      ids[table] = seen;
    }
    for (final row in tables['schedules']!) {
      if (!ids['drugs']!.contains(row['drug_id']))
        throw const FormatException('Missing drug reference.');
    }
    final schedulesById = {
      for (final row in tables['schedules']!) row['id']: row
    };
    for (final row in tables['medicationLogs']!) {
      if (!ids['drugs']!.contains(row['drug_id']) ||
          !ids['schedules']!.contains(row['schedule_id']) ||
          schedulesById[row['schedule_id']]?['drug_id'] != row['drug_id'])
        throw const FormatException('Missing medication reference.');
    }
    final inventoryDrugIds = <Object?>{};
    for (final row in tables['drugInventory']!) {
      if (!ids['drugs']!.contains(row['drug_id']) ||
          !inventoryDrugIds.add(row['drug_id']))
        throw const FormatException('Invalid inventory drug.');
    }
    return BackupRestorePayload(tables);
  }

  void _validateReadings(Map<String, Object?> report) {
    final readings = report['readings'];
    if (readings is! List) throw const FormatException('Invalid readings.');
    final seen = <String>{};
    for (final raw in readings) {
      if (raw is! Map<String, dynamic>)
        throw const FormatException('Invalid reading.');
      if (raw.keys.any((key) => !{
                'id',
                'report_id',
                'hormone_type',
                'value',
                'unit',
                'notes'
              }.contains(key)) ||
          raw['id'] is! String ||
          (raw['id'] as String).isEmpty ||
          !seen.add(raw['id'] as String) ||
          raw['report_id'] != report['id'] ||
          raw['hormone_type'] is! String ||
          !_enumValues['hormone_type']!.contains(raw['hormone_type']) ||
          raw['value'] is! num ||
          !(raw['value'] as num).isFinite ||
          (raw['value'] as num) < 0 ||
          raw['unit'] is! String ||
          raw['notes'] != null && raw['notes'] is! String)
        throw const FormatException('Invalid reading fields.');
    }
    report['readings'] = readings
        .map((r) => Map<String, Object?>.from(r as Map<String, dynamic>))
        .toList();
  }
}
