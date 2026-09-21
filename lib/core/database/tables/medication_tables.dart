/// SQL DDL for all medication-related tables.
///
/// v4 (R52-C-1) adds 4 sync-metadata columns to drugs / medication_schedules
/// / medication_logs per SPEC-cloud-sync.md Appendix E. drug_inventory is
/// OUT OF SCOPE for the medication SyncQueue prototype (deferred to R53;
/// per-device consumption semantics).
abstract class MedicationTables {
  /// Creates the `drugs` table.
  static const String createDrugsTable = '''
    CREATE TABLE drugs (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      generic_name TEXT NOT NULL,
      category TEXT NOT NULL,
      administration_route TEXT NOT NULL,
      default_dosage_unit TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      notes TEXT,
      dirty INTEGER NOT NULL DEFAULT 0,
      synced_at TEXT,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT NOT NULL DEFAULT ''
    )
  ''';

  /// Creates the `medication_schedules` table.
  static const String createSchedulesTable = '''
    CREATE TABLE medication_schedules (
      id TEXT PRIMARY KEY,
      drug_id TEXT NOT NULL,
      dosage_amount REAL NOT NULL,
      dosage_unit TEXT NOT NULL,
      frequency_type TEXT NOT NULL,
      frequency_value TEXT NOT NULL,
      administration_route TEXT NOT NULL,
      schedule_times TEXT NOT NULL,
      interval_days INTEGER,
      start_date TEXT NOT NULL,
      end_date TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      dirty INTEGER NOT NULL DEFAULT 0,
      synced_at TEXT,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (drug_id) REFERENCES drugs(id) ON DELETE CASCADE
    )
  ''';

  /// Creates the `medication_logs` table.
  static const String createLogsTable = '''
    CREATE TABLE medication_logs (
      id TEXT PRIMARY KEY,
      schedule_id TEXT NOT NULL,
      drug_id TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      dosage_amount REAL NOT NULL,
      dosage_unit TEXT NOT NULL,
      administration_route TEXT NOT NULL,
      status TEXT NOT NULL,
      injection_site TEXT,
      patch_site TEXT,
      patch_count INTEGER,
      gel_pumps INTEGER,
      skin_reaction TEXT,
      notes TEXT,
      dirty INTEGER NOT NULL DEFAULT 0,
      synced_at TEXT,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (schedule_id) REFERENCES medication_schedules(id),
      FOREIGN KEY (drug_id) REFERENCES drugs(id) ON DELETE CASCADE
    )
  ''';

  /// Creates the `drug_inventory` table.
  static const String createInventoryTable = '''
    CREATE TABLE drug_inventory (
      id TEXT PRIMARY KEY,
      drug_id TEXT NOT NULL UNIQUE,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL,
      purchase_date TEXT NOT NULL,
      expiration_date TEXT,
      batch_number TEXT,
      notes TEXT,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (drug_id) REFERENCES drugs(id) ON DELETE CASCADE
    )
  ''';

  /// All medication table creation statements.
  static const List<String> allCreateStatements = [
    createDrugsTable,
    createSchedulesTable,
    createLogsTable,
    createInventoryTable,
  ];

  /// Indices for common medication queries.
  static const List<String> createIndices = [
    'CREATE INDEX idx_schedules_drug_id ON medication_schedules(drug_id)',
    'CREATE INDEX idx_logs_drug_id ON medication_logs(drug_id)',
    'CREATE INDEX idx_logs_timestamp ON medication_logs(timestamp)',
    'CREATE INDEX idx_logs_schedule_id ON medication_logs(schedule_id)',
    'CREATE INDEX idx_inventory_drug_id ON drug_inventory(drug_id)',
    // Partial indices for sync (v4) — only rows pending push are
    // indexed; avoids carrying the index weight for the clean majority.
    'CREATE INDEX idx_drugs_dirty ON drugs(dirty) WHERE dirty = 1',
    'CREATE INDEX idx_schedules_dirty ON medication_schedules(dirty) WHERE dirty = 1',
    'CREATE INDEX idx_logs_dirty ON medication_logs(dirty) WHERE dirty = 1',
  ];

  /// v3 → v4 migration: add sync metadata columns to the three
  /// user-mutable tables. Per SPEC-cloud-sync.md Appendix E.
  ///
  /// `ALTER TABLE ADD COLUMN` is lossless; existing rows pick up the
  /// DEFAULT values atomically. The `updated_at` backfill query
  /// below populates it from `created_at` (drugs) or `timestamp`
  /// (logs) where available, falling back to `datetime('now')`.
  static const List<String> v4SyncMetaColumns = [
    "ALTER TABLE drugs ADD COLUMN dirty INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE drugs ADD COLUMN synced_at TEXT",
    "ALTER TABLE drugs ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE drugs ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE medication_schedules ADD COLUMN dirty INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE medication_schedules ADD COLUMN synced_at TEXT",
    "ALTER TABLE medication_schedules ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE medication_schedules ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
    "ALTER TABLE medication_logs ADD COLUMN dirty INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE medication_logs ADD COLUMN synced_at TEXT",
    "ALTER TABLE medication_logs ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
    "ALTER TABLE medication_logs ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
  ];

  /// Backfill `updated_at` for rows already in the DB before v4. Done
  /// once after the ALTERs; sets a sensible mutation timestamp so the
  /// first sync cycle has a basis for ConflictResolver to operate on.
  static const List<String> v4Backfill = [
    "UPDATE drugs SET updated_at = COALESCE(NULLIF(updated_at,''), created_at, datetime('now')) WHERE updated_at = ''",
    // schedules: no created_at column today — use 'now' as floor
    "UPDATE medication_schedules SET updated_at = COALESCE(NULLIF(updated_at,''), datetime('now')) WHERE updated_at = ''",
    // logs: 'timestamp' is the dose-time, not the row-mutation time;
    // but using it is a better approximation than 'now'.
    "UPDATE medication_logs SET updated_at = COALESCE(NULLIF(updated_at,''), timestamp, datetime('now')) WHERE updated_at = ''",
  ];

  /// v4 migration combined (ALTERs + backfill + new partial indices).
  static const List<String> v4Migration = [
    ...v4SyncMetaColumns,
    ...v4Backfill,
    'CREATE INDEX idx_drugs_dirty ON drugs(dirty) WHERE dirty = 1',
    'CREATE INDEX idx_schedules_dirty ON medication_schedules(dirty) WHERE dirty = 1',
    'CREATE INDEX idx_logs_dirty ON medication_logs(dirty) WHERE dirty = 1',
  ];
}
