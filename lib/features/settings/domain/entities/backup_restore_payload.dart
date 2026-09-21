/// Fully validated SQL-backed backup rows, independent of database APIs.
class BackupRestorePayload {
  /// Creates a payload after the import validator has checked all rows.
  const BackupRestorePayload(this.tables);

  /// Rows keyed by the seven supported backup collection names.
  final Map<String, List<Map<String, Object?>>> tables;

  /// Number of top-level records (readings are nested in blood tests).
  int get recordCount =>
      tables.values.fold(0, (sum, rows) => sum + rows.length);
}
