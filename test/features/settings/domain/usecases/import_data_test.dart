import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/backup/backup_vault_service.dart';
import 'package:hananote/core/crypto/crypto_engine.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/entities/backup_restore_payload.dart';
import 'package:hananote/features/settings/domain/repositories/backup_restore_repository.dart';
import 'package:hananote/features/settings/domain/usecases/export_data.dart';
import 'package:hananote/features/settings/domain/usecases/import_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockBackupRepository extends Mock implements BackupRestoreRepository {}

Map<String, Object?> _emptyBackup() => {
      'format': 'hananote.records.v1',
      'version': '1.0',
      'exportDate': '2026-09-22T00:00:00Z',
      'drugs': <Object>[],
      'schedules': <Object>[],
      'medicationLogs': <Object>[],
      'drugInventory': <Object>[],
      'bloodTests': <Object>[],
      'journals': <Object>[],
      'measurements': <Object>[],
    };

Uint8List _bytes(Map<String, Object?> data) =>
    Uint8List.fromList(utf8.encode(jsonEncode(data)));

void main() {
  late _MockBackupRepository repository;
  late BackupVaultService vault;
  late ImportData importer;

  setUpAll(() {
    registerFallbackValue(const BackupRestorePayload({}));
  });

  setUp(() {
    repository = _MockBackupRepository();
    vault = BackupVaultService(CryptoEngine());
    importer = ImportData(repository, vault);
  });

  test('test: malformed root and missing collections never enter restore',
      () async {
    for (final raw in [
      <String, Object?>{},
      {'version': '1.0'},
      {'format': 'hananote.records.v1', 'version': '2.0'}
    ]) {
      final result = await importer(
          backupBytes: _bytes(raw),
          password: '',
          format: ImportBackupFormat.legacyJson);
      expect(result.isLeft(), isTrue);
    }
    verifyNever(() => repository.restore(any()));
  });

  test('test: invalid later record rejects all writes', () async {
    final data = _emptyBackup();
    data['drugs'] = [
      {
        'id': 'drug-1',
        'name': 'synthetic',
        'generic_name': '',
        'category': 'estrogen',
        'administration_route': 'oral',
        'default_dosage_unit': 'mg',
        'is_active': 1,
        'created_at': '2026-01-01T00:00:00Z'
      },
      {'id': 'drug-2', 'name': 'bad synthetic'},
    ];
    final result = await importer(
        backupBytes: _bytes(data),
        password: '',
        format: ImportBackupFormat.legacyJson);
    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.restore(any()));
  });

  test('test: vault export and import round trip preserves all collections',
      () async {
    final payload = BackupRestorePayload({
      'drugs': [
        {
          'id': 'drug-1',
          'name': 'synthetic',
          'generic_name': '',
          'category': 'estrogen',
          'administration_route': 'oral',
          'default_dosage_unit': 'mg',
          'is_active': 1,
          'created_at': '2026-01-01T00:00:00Z'
        }
      ],
      'schedules': [
        {
          'id': 'schedule-1',
          'drug_id': 'drug-1',
          'dosage_amount': 1.0,
          'dosage_unit': 'mg',
          'frequency_type': 'daily',
          'frequency_value': '1',
          'administration_route': 'oral',
          'schedule_times': '[{"hour":9,"minute":0}]',
          'start_date': '2026-01-01T00:00:00Z',
          'is_active': 1
        }
      ],
      'medicationLogs': [
        {
          'id': 'log-1',
          'schedule_id': 'schedule-1',
          'drug_id': 'drug-1',
          'timestamp': '2026-01-02T09:00:00Z',
          'dosage_amount': 1.0,
          'dosage_unit': 'mg',
          'administration_route': 'oral',
          'status': 'taken'
        }
      ],
      'drugInventory': [
        {
          'id': 'inventory-1',
          'drug_id': 'drug-1',
          'quantity': 10.0,
          'unit': 'mg',
          'purchase_date': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z'
        }
      ],
      'bloodTests': [
        {
          'id': 'report-1',
          'test_date': '2026-01-03T00:00:00Z',
          'created_at': '2026-01-03T00:00:00Z',
          'readings': [
            {
              'id': 'reading-1',
              'report_id': 'report-1',
              'hormone_type': 'estradiol',
              'value': 120.0,
              'unit': 'pg/mL'
            }
          ]
        }
      ],
      'journals': [
        {
          'id': 'journal-1',
          'date': '2026-01-04T00:00:00Z',
          'content': 'synthetic',
          'mood': 'neutral',
          'created_at': '2026-01-04T00:00:00Z'
        }
      ],
      'measurements': [
        {
          'id': 'measurement-1',
          'date': '2026-01-05T00:00:00Z',
          'created_at': '2026-01-05T00:00:00Z',
          'weight': 60.0
        }
      ],
    });
    when(() => repository.exportRecords())
        .thenAnswer((_) async => right(payload));
    when(() => repository.restore(any())).thenAnswer((invocation) async {
      final restored =
          invocation.positionalArguments.single as BackupRestorePayload;
      expect(restored.tables, payload.tables);
      return right(restored.recordCount);
    });
    final exported = await ExportData(repository, vault)(
        password: 'separate backup password');
    expect(exported.isRight(), isTrue);
    final imported = await importer(
      backupBytes: exported.getRight().toNullable()!,
      password: 'separate backup password',
      format: ImportBackupFormat.vault,
    );
    expect(imported.getRight().toNullable(), 7);
    verify(() => repository.restore(any())).called(1);
  });

  test('test: repository failure is never reported as success', () async {
    when(() => repository.restore(any())).thenAnswer((_) async => left(
          const DatabaseFailure(message: 'rollback'),
        ));
    final result = await importer(
        backupBytes: _bytes(_emptyBackup()),
        password: '',
        format: ImportBackupFormat.legacyJson);
    expect(result.isLeft(), isTrue);
  });
  test('test: plaintext and altered magic fail the vault path', () async {
    final plain = _bytes(_emptyBackup());
    final plaintextResult = await importer(
      backupBytes: plain,
      password: 'secret',
      format: ImportBackupFormat.vault,
    );
    expect(plaintextResult.isLeft(), isTrue);
    final encrypted = await vault.encryptJson(
      plaintextJson: jsonEncode(_emptyBackup()),
      password: 'secret',
    );
    final envelope = jsonDecode(utf8.decode(encrypted.getRight().toNullable()!))
        as Map<String, dynamic>;
    envelope['magic'] = 'INVALID';
    final tamperedResult = await importer(
      backupBytes: _bytes(envelope),
      password: 'secret',
      format: ImportBackupFormat.vault,
    );
    expect(tamperedResult.isLeft(), isTrue);
    verifyNever(() => repository.restore(any()));
  });

  test('test: invalid boolean and negative reading fail before restore',
      () async {
    final booleanBackup = _emptyBackup();
    booleanBackup['drugs'] = [
      {
        'id': 'drug-1',
        'name': 'synthetic',
        'generic_name': '',
        'category': 'estrogen',
        'administration_route': 'oral',
        'default_dosage_unit': 'mg',
        'is_active': 2,
        'created_at': '2026-01-01T00:00:00Z'
      }
    ];
    final boolResult = await importer(
      backupBytes: _bytes(booleanBackup),
      password: '',
      format: ImportBackupFormat.legacyJson,
    );
    expect(boolResult.isLeft(), isTrue);
    final readingBackup = _emptyBackup();
    readingBackup['bloodTests'] = [
      {
        'id': 'report-1',
        'test_date': '2026-01-01T00:00:00Z',
        'created_at': '2026-01-01T00:00:00Z',
        'readings': [
          {
            'id': 'reading-1',
            'report_id': 'report-1',
            'hormone_type': 'estradiol',
            'value': -1,
            'unit': 'pg/mL'
          }
        ]
      }
    ];
    final readingResult = await importer(
      backupBytes: _bytes(readingBackup),
      password: '',
      format: ImportBackupFormat.legacyJson,
    );
    expect(readingResult.isLeft(), isTrue);
    verifyNever(() => repository.restore(any()));
  });
  test('test: exported medication with empty sync timestamp remains importable',
      () async {
    final data = _emptyBackup();
    data['drugs'] = [
      {
        'id': 'drug-1',
        'name': 'synthetic',
        'generic_name': '',
        'category': 'estrogen',
        'administration_route': 'oral',
        'default_dosage_unit': 'mg',
        'is_active': 1,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '',
        'is_deleted': 0,
        'dirty': 1
      }
    ];
    when(() => repository.restore(any())).thenAnswer((_) async => right(1));
    final result = await importer(
        backupBytes: _bytes(data),
        password: '',
        format: ImportBackupFormat.legacyJson);
    expect(result.getRight().toNullable(), 1);
  });
}
