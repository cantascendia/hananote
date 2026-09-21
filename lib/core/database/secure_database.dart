import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/crypto/key_manager.dart';
import 'package:hananote/core/database/database_factory.dart';
import 'package:hananote/core/database/tables/blood_test_tables.dart';
import 'package:hananote/core/database/tables/journal_tables.dart';
import 'package:hananote/core/database/tables/measurement_tables.dart';
import 'package:hananote/core/database/tables/medication_tables.dart';
import 'package:hananote/core/database/tables/photo_tables.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Wraps SQLCipher database connection.
@lazySingleton
class SecureDatabase {
  /// Constructor for [SecureDatabase].
  SecureDatabase(this._keyManager);

  static const int _databaseVersion = 4;

  final KeyManager _keyManager;
  Database? _db;

  /// Returns the full database file path used by the app.
  Future<String> getDatabasePath() async {
    final dbPath = await getPlatformDatabasesPath();
    return join(dbPath, 'hananote_secure.db');
  }

  /// Returns the open database instance.
  ///
  /// Throws a [StateError] when the database has not been opened yet.
  Database get database {
    final db = _db;
    if (db == null || !db.isOpen) {
      throw StateError('Database is not open.');
    }
    return db;
  }

  /// Opens the encrypted SQLCipher database and runs pending migrations.
  Future<Either<Failure, Database>> open() async {
    try {
      if (_db != null && _db!.isOpen) return right(_db!);

      final path = await getDatabasePath();

      // On web, skip encryption (SQLCipher not available).
      String? dbPassword;
      if (!kDatabaseIsWeb) {
        // Retrieve the 256-bit key from KeyManager, base64 encode it to use
        // as SQLCipher password
        final key = await _keyManager.getKey();
        if (key == null) {
          return left(
            const DatabaseFailure(
              message: 'Database key not available. Cannot open database.',
            ),
          );
        }
        dbPassword = base64Encode(key);
      }

      _db = await openPlatformDatabase(
        path,
        password: dbPassword,
        version: _databaseVersion,
        onCreate: (db, version) async {
          await _runInitialMigrations(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _runUpgradeMigrations(db, oldVersion, newVersion);
        },
      );

      return right(_db!);
    } catch (e) {
      return left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Closes the current database connection when it is open.
  Future<Either<Failure, void>> close() async {
    try {
      if (_db != null && _db!.isOpen) {
        await _db!.close();
        _db = null;
      }
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Runs [action] inside one SQL transaction on the open database.
  ///
  /// Any exception thrown by [action] rolls back all writes in the transaction.
  Future<T> runInTransaction<T>(Future<T> Function(Transaction txn) action) {
    return database.transaction<T>(action);
  }

  /// Runs database migrations explicitly against the current open connection.
  Future<Either<Failure, void>> runMigrations() async {
    try {
      // Migration logic will be implemented here.
      if (_db == null || !_db!.isOpen) {
        return left(const DatabaseFailure(message: 'Database is not open.'));
      }
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<void> _runInitialMigrations(Database db) async {
    for (final statement in MedicationTables.allCreateStatements) {
      await db.execute(statement);
    }

    for (final statement in BloodTestTables.allCreateStatements) {
      await db.execute(statement);
    }

    for (final statement in JournalTables.allCreateStatements) {
      await db.execute(statement);
    }

    for (final statement in MeasurementTables.allCreateStatements) {
      await db.execute(statement);
    }

    for (final statement in PhotoTables.allCreateStatements) {
      await db.execute(statement);
    }

    for (final statement in MedicationTables.createIndices) {
      await db.execute(statement);
    }

    for (final statement in BloodTestTables.createIndices) {
      await db.execute(statement);
    }

    for (final statement in JournalTables.createIndices) {
      await db.execute(statement);
    }

    for (final statement in MeasurementTables.createIndices) {
      await db.execute(statement);
    }

    for (final statement in PhotoTables.createIndices) {
      await db.execute(statement);
    }
  }

  Future<void> _runUpgradeMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      for (final statement in MeasurementTables.allCreateStatements) {
        await db.execute(statement);
      }

      for (final statement in MeasurementTables.createIndices) {
        await db.execute(statement);
      }
    }

    if (oldVersion < 3 && newVersion >= 3) {
      for (final statement in PhotoTables.allCreateStatements) {
        await db.execute(statement);
      }

      for (final statement in PhotoTables.createIndices) {
        await db.execute(statement);
      }
    }

    // v4 — R52-C-1 cloud sync prototype.
    // Adds dirty / synced_at / is_deleted / updated_at columns to the
    // three user-mutable medication tables, plus partial indices on
    // `dirty=1` for the SyncQueue takeDirty() query path.
    // Per SPEC-cloud-sync.md Appendix E.
    if (oldVersion < 4 && newVersion >= 4) {
      for (final statement in MedicationTables.v4Migration) {
        await db.execute(statement);
      }
    }
  }
}
