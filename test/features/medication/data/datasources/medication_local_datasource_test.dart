import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/features/medication/data/datasources/medication_local_datasource.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../fixtures.dart';

class _MockSecureDatabase extends Mock implements SecureDatabase {}

class _MockDatabase extends Mock implements Database {}

void main() {
  late _MockDatabase database;
  late _MockSecureDatabase secureDatabase;
  late MedicationLocalDataSource dataSource;

  setUp(() {
    database = _MockDatabase();
    secureDatabase = _MockSecureDatabase();
    when(() => secureDatabase.database).thenReturn(database);
    dataSource = MedicationLocalDataSourceImpl(secureDatabase);
  });

  group('MedicationLocalDataSource', () {
    // R52-C-1 v4: queries now filter `is_deleted = 0 OR is_deleted IS NULL`
    // to hide sync tombstones from the UI. Per Test-Lock §20.3 rule #1
    // (spec change ratified in SPEC-cloud-sync.md Appendix E).
    test('gets all drugs from the drugs table', () async {
      final drug = buildDrugModel();
      when(
        () => database.query(
          'drugs',
          where: 'is_deleted = 0 OR is_deleted IS NULL',
          orderBy: 'created_at DESC',
        ),
      ).thenAnswer((_) async => [drug.toJson()]);

      final result = await dataSource.getAllDrugs();

      expect(result, [drug]);
      verify(
        () => database.query(
          'drugs',
          where: 'is_deleted = 0 OR is_deleted IS NULL',
          orderBy: 'created_at DESC',
        ),
      ).called(1);
    });

    test('loads the latest schedule for a drug', () async {
      final schedule = buildScheduleModel();
      when(
        () => database.query(
          'medication_schedules',
          where: 'drug_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
          whereArgs: [schedule.drugId],
          orderBy: 'is_active DESC, start_date DESC',
          limit: 1,
        ),
      ).thenAnswer((_) async => [schedule.toJson()]);

      final result = await dataSource.getScheduleForDrug(schedule.drugId);

      expect(result, schedule);
    });

    test('builds parameterized date queries for drug logs', () async {
      final from = DateTime(2026, 3, 22);
      final to = DateTime(2026, 3, 23, 23, 59);
      final log = buildLogModel(timestamp: DateTime(2026, 3, 23, 8));
      when(
        () => database.query(
          'medication_logs',
          where: 'drug_id = ? AND '
              '(is_deleted = 0 OR is_deleted IS NULL) AND '
              'timestamp >= ? AND timestamp <= ?',
          whereArgs: [
            'drug-1',
            from.toIso8601String(),
            to.toIso8601String(),
          ],
          orderBy: 'timestamp DESC',
        ),
      ).thenAnswer((_) async => [log.toJson()]);

      final result = await dataSource.getLogsForDrug(
        'drug-1',
        from: from,
        to: to,
      );

      expect(result, [log]);
    });

    test('upserts inventory with replace conflict strategy', () async {
      final inventory = buildInventoryModel();
      when(
        () => database.insert(
          'drug_inventory',
          inventory.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).thenAnswer((_) async => 1);

      await dataSource.upsertInventory(inventory);

      verify(
        () => database.insert(
          'drug_inventory',
          inventory.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
    });
  });
}
