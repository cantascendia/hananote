/// Contract for managing the encrypted database lifecycle.
abstract class SecureDatabase {
  /// Opens the encrypted database connection.
  Future<void> open();

  /// Closes the encrypted database connection.
  Future<void> close();

  /// Whether the database connection is currently active.
  bool get isOpen;
}
