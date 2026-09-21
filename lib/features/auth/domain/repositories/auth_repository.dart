import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';

/// Contract for app-authentication and startup-security flows.
abstract interface class AuthRepository {
  /// Returns persisted authentication settings.
  Future<Either<Failure, AuthSettings>> getSettings();

  /// Persists [settings].
  Future<Either<Failure, void>> saveSettings(AuthSettings settings);

  /// Returns whether credential material or an encrypted database already exists.
  Future<Either<Failure, bool>> hasProtectedSetupData();

  /// Sets up the master key from a new PIN.
  Future<Either<Failure, void>> setupPassword(String pin);

  /// Removes only incomplete first-run setup artifacts.
  Future<Either<Failure, void>> discardIncompleteSetup();

  /// Verifies the supplied PIN.
  Future<Either<Failure, bool>> verifyPassword(String pin);

  /// Changes the PIN from [oldPin] to [newPin].
  Future<Either<Failure, void>> changePassword(String oldPin, String newPin);

  /// Deletes all protected data and credentials.
  Future<Either<Failure, void>> deleteAllData();

  /// Returns whether biometric auth is available.
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Performs biometric authentication.
  Future<Either<Failure, bool>> authenticateBiometric();

  /// Opens the encrypted database.
  Future<Either<Failure, void>> openDatabase();
}
