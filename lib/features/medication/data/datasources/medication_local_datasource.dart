import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/features/medication/data/models/drug_inventory_model.dart';
import 'package:hananote/features/medication/data/models/drug_model.dart';
import 'package:hananote/features/medication/data/models/medication_log_model.dart';
import 'package:hananote/features/medication/data/models/medication_schedule_model.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Direct database operations for medication data.
///
/// No business logic lives here; this layer performs CRUD only.
abstract interface class MedicationLocalDataSource {
  /// Returns all stored drugs.
  Future<List<DrugModel>> getAllDrugs();

  /// Returns a single drug by [id], if present.
  Future<DrugModel?> getDrugById(String id);

  /// Inserts a new [drug].
  Future<void> insertDrug(DrugModel drug);

  /// Updates an existing [drug].
  Future<void> updateDrug(DrugModel drug);

  /// Deletes the drug with [id].
  Future<void> deleteDrug(String id);

  /// Returns the active or latest schedule for [drugId], if present.
  Future<MedicationScheduleModel?> getScheduleForDrug(String drugId);

  /// Inserts a new [schedule].
  Future<void> insertSchedule(MedicationScheduleModel schedule);

  /// Updates an existing [schedule].
  Future<void> updateSchedule(MedicationScheduleModel schedule);

  /// Deletes the schedule with [id].
  Future<void> deleteSchedule(String id);

  /// Inserts a medication [log].
  Future<void> insertLog(MedicationLogModel log);

  /// Returns logs for [drugId] in the optional date range.
  Future<List<MedicationLogModel>> getLogsForDrug(
    String drugId, {
    DateTime? from,
    DateTime? to,
  });

  /// Returns all logs recorded on [date].
  Future<List<MedicationLogModel>> getLogsForDate(DateTime date);

  /// Returns the inventory for [drugId], if present.
  Future<DrugInventoryModel?> getInventoryForDrug(String drugId);

  /// Inserts or replaces [inventory] for its drug.
  Future<void> upsertInventory(DrugInventoryModel inventory);
}

/// Default SQLite-backed implementation of [MedicationLocalDataSource].
///
/// v4 (R52-C-1) wires cloud-sync metadata invisible to the domain layer:
/// every write sets `dirty = 1, updated_at = now()`; every delete becomes
/// a soft tombstone (`is_deleted = 1, dirty = 1, updated_at = now()`).
/// Read queries filter `is_deleted = 0` so tombstones don't surface in
/// the UI. Per SPEC-cloud-sync.md Appendix E.
@LazySingleton(as: MedicationLocalDataSource)
class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  /// Creates a [MedicationLocalDataSourceImpl].
  MedicationLocalDataSourceImpl(this._secureDatabase);

  final SecureDatabase _secureDatabase;

  Database get _db => _secureDatabase.database;

  /// Injects sync metadata into any model.toJson() before INSERT/UPDATE.
  Map<String, dynamic> _withDirty(Map<String, dynamic> payload) => {
        ...payload,
        'dirty': 1,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  @override
  Future<List<DrugModel>> getAllDrugs() async {
    final rows = await _db.query(
      'drugs',
      where: 'is_deleted = 0 OR is_deleted IS NULL',
      orderBy: 'created_at DESC',
    );
    return rows.map(DrugModel.fromJson).toList();
  }

  @override
  Future<DrugModel?> getDrugById(String id) async {
    final rows = await _db.query(
      'drugs',
      where: 'id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return DrugModel.fromJson(rows.first);
  }

  @override
  Future<void> insertDrug(DrugModel drug) async {
    await _db.insert('drugs', _withDirty(drug.toJson()));
  }

  @override
  Future<void> updateDrug(DrugModel drug) async {
    await _db.update(
      'drugs',
      _withDirty(drug.toJson()),
      where: 'id = ?',
      whereArgs: [drug.id],
    );
  }

  @override
  Future<void> deleteDrug(String id) async {
    // Soft delete + tombstone for sync. The row stays in SQLCipher
    // until the next push round + R53 GC sweep.
    await _db.rawUpdate(
      'UPDATE drugs SET is_deleted = 1, dirty = 1, updated_at = ? '
      'WHERE id = ?',
      [DateTime.now().toUtc().toIso8601String(), id],
    );
  }

  @override
  Future<MedicationScheduleModel?> getScheduleForDrug(String drugId) async {
    final rows = await _db.query(
      'medication_schedules',
      where: 'drug_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)',
      whereArgs: [drugId],
      orderBy: 'is_active DESC, start_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return MedicationScheduleModel.fromJson(rows.first);
  }

  @override
  Future<void> insertSchedule(MedicationScheduleModel schedule) async {
    await _db.insert(
      'medication_schedules',
      _withDirty(schedule.toJson()),
    );
  }

  @override
  Future<void> updateSchedule(MedicationScheduleModel schedule) async {
    await _db.update(
      'medication_schedules',
      _withDirty(schedule.toJson()),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _db.rawUpdate(
      'UPDATE medication_schedules SET is_deleted = 1, dirty = 1, '
      'updated_at = ? WHERE id = ?',
      [DateTime.now().toUtc().toIso8601String(), id],
    );
  }

  @override
  Future<void> insertLog(MedicationLogModel log) async {
    await _db.insert('medication_logs', _withDirty(log.toJson()));
  }

  @override
  Future<List<MedicationLogModel>> getLogsForDrug(
    String drugId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final clauses = <String>[
      'drug_id = ?',
      '(is_deleted = 0 OR is_deleted IS NULL)',
    ];
    final args = <Object?>[drugId];

    if (from != null) {
      clauses.add('timestamp >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      clauses.add('timestamp <= ?');
      args.add(to.toIso8601String());
    }

    final rows = await _db.query(
      'medication_logs',
      where: clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'timestamp DESC',
    );
    return rows.map(MedicationLogModel.fromJson).toList();
  }

  @override
  Future<List<MedicationLogModel>> getLogsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    final rows = await _db.query(
      'medication_logs',
      where: 'timestamp >= ? AND timestamp <= ? '
          'AND (is_deleted = 0 OR is_deleted IS NULL)',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return rows.map(MedicationLogModel.fromJson).toList();
  }

  @override
  Future<DrugInventoryModel?> getInventoryForDrug(String drugId) async {
    final rows = await _db.query(
      'drug_inventory',
      where: 'drug_id = ?',
      whereArgs: [drugId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return DrugInventoryModel.fromJson(rows.first);
  }

  @override
  Future<void> upsertInventory(DrugInventoryModel inventory) async {
    await _db.insert(
      'drug_inventory',
      inventory.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
