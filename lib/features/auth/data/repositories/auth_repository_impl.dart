import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/crypto/key_manager.dart';
import 'package:hananote/core/database/secure_database.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class _AuthRepositoryException implements Exception {
  const _AuthRepositoryException(this.failure);

  final Failure failure;
}

/// Default repository for startup authentication flows.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  /// Creates [AuthRepositoryImpl].
  AuthRepositoryImpl(
    this._localDataSource,
    this._keyManager,
    this._secureDatabase,
    this._secureStorage,
    this._localAuthentication,
  );

  final AuthLocalDataSource _localDataSource;
  final KeyManager _keyManager;
  final SecureDatabase _secureDatabase;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuthentication;

  bool _ownsIncompleteSetup = false;
  bool _setupInProgress = false;

  @override
  Future<Either<Failure, AuthSettings>> getSettings() {
    return _guard(() async {
      final hasSettings = await _localDataSource.hasSettings();
      final hasProtectedData = await _hasProtectedSetupData();
      if (!hasSettings && hasProtectedData) {
        throw const _AuthRepositoryException(
          Failure.auth(message: 'auth_settings_missing'),
        );
      }

      final settings = await _localDataSource.getSettings();
      if (!settings.isSetup && hasProtectedData) {
        throw const _AuthRepositoryException(
          Failure.auth(message: 'auth_settings_missing'),
        );
      }
      return settings;
    });
  }

  @override
  Future<Either<Failure, void>> saveSettings(AuthSettings settings) {
    return _guard(() => _localDataSource.saveSettings(settings));
  }

  @override
  Future<Either<Failure, bool>> hasProtectedSetupData() {
    return _guard(_hasProtectedSetupData);
  }

  @override
  Future<Either<Failure, void>> setupPassword(String pin) {
    return _guard(() async {
      if (_setupInProgress) {
        throw const _AuthRepositoryException(
          Failure.auth(message: 'setup_in_progress'),
        );
      }

      _setupInProgress = true;
      try {
        if (await _hasProtectedSetupData()) {
          throw const _AuthRepositoryException(
            Failure.auth(message: 'existing_credentials_require_unlock'),
          );
        }
        _ownsIncompleteSetup = true;
        try {
          await _keyManager.initializeKey(pin);
        } catch (error, stackTrace) {
          try {
            await _discardOwnedIncompleteSetup();
          } catch (_) {
            // Preserve the setup failure. A later startup will still fail closed
            // if any credential material survived cleanup.
          }
          Error.throwWithStackTrace(error, stackTrace);
        }
      } finally {
        _setupInProgress = false;
      }
    });
  }

  @override
  Future<Either<Failure, void>> discardIncompleteSetup() {
    return _guard(() async {
      if (!_ownsIncompleteSetup) {
        throw const _AuthRepositoryException(
          Failure.auth(message: 'no_incomplete_setup_owned'),
        );
      }

      await _discardOwnedIncompleteSetup();
    });
  }

  @override
  Future<Either<Failure, bool>> verifyPassword(String pin) {
    return _guard(() => _keyManager.verifyPassword(pin));
  }

  @override
  Future<Either<Failure, void>> changePassword(String oldPin, String newPin) {
    // Rotating only the PIN-derived key would orphan the existing database
    // and encrypted photos. Keep credentials unchanged until a transactional
    // migration for both stores is available. This API has no v1 UI entry.
    return Future.value(
      left(const Failure.auth(message: 'pin_change_unavailable')),
    );
  }

  @override
  Future<Either<Failure, void>> deleteAllData() {
    return _guard(() async {
      await _secureDatabase.close();
      if (!kIsWeb) {
        await deleteDatabase(await _secureDatabase.getDatabasePath());
      }
      await _keyManager.deleteKey();
      await _secureStorage.deleteAll();
    });
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() {
    return _guard(() async {
      // Biometric authentication is not available on web.
      if (kIsWeb || await _keyManager.getKey() == null) return false;
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final supported = await _localAuthentication.isDeviceSupported();
      return canCheck && supported;
    });
  }

  @override
  Future<Either<Failure, bool>> authenticateBiometric() {
    return _guard(() async {
      // Biometric authentication is not available on web.
      if (kIsWeb || await _keyManager.getKey() == null) return false;
      return _localAuthentication.authenticate(
        localizedReason: '请验证身份以访问 HanaNote',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    });
  }

  @override
  Future<Either<Failure, void>> openDatabase() {
    return _guard(() async {
      final result = await _secureDatabase.open();
      if (result.isLeft()) {
        throw const _AuthRepositoryException(
          Failure.database(message: 'database_open_failed'),
        );
      }
      _ownsIncompleteSetup = false;
    });
  }

  Future<void> _discardOwnedIncompleteSetup() async {
    await _secureDatabase.close();
    if (!kIsWeb) {
      final path = await _secureDatabase.getDatabasePath();
      if (await databaseExists(path)) {
        await deleteDatabase(path);
      }
    }
    await _keyManager.deleteKey();
    await _localDataSource.clearSettings();
    _ownsIncompleteSetup = false;
  }

  Future<bool> _hasProtectedSetupData() async {
    if (await _keyManager.hasStoredCredentialMaterial()) return true;
    if (kIsWeb) return false;
    return databaseExists(await _secureDatabase.getDatabasePath());
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on _AuthRepositoryException catch (error) {
      return left(error.failure);
    } catch (_) {
      return left(const Failure.auth(message: 'auth_operation_failed'));
    }
  }
}
