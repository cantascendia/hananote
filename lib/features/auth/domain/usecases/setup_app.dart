import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Parameters for [SetupApp].
class SetupAppParams {
  /// Creates [SetupAppParams].
  const SetupAppParams({
    required this.pin,
    this.biometricEnabled = false,
    this.appDisplayName = 'HanaNote',
    this.appIconKey = 'default',
    this.autoLockMinutes = 0,
    this.maxFailedAttempts = 0,
  });

  /// Initial PIN.
  final String pin;

  /// Whether biometrics should be enabled.
  final bool biometricEnabled;

  /// Display name to persist for disguise mode.
  final String appDisplayName;

  /// App icon key to persist for disguise mode.
  final String appIconKey;

  /// Auto-lock timeout in minutes.
  final int autoLockMinutes;

  /// Maximum failed attempts before wipe. `0` disables wipe.
  final int maxFailedAttempts;
}

/// Performs the first-run setup flow.
@injectable
class SetupApp {
  /// Creates [SetupApp].
  SetupApp(this._repository);

  final AuthRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, void>> call(SetupAppParams params) async {
    if (!_isValidPin(params.pin)) {
      return left(
        const Failure.validation(message: 'PIN must be exactly 6 digits.'),
      );
    }

    final protectedDataResult = await _repository.hasProtectedSetupData();
    if (protectedDataResult.isLeft()) {
      return protectedDataResult.fold(left, (_) => right(null));
    }
    if (protectedDataResult.getOrElse((_) => true)) {
      return left(
        const Failure.auth(message: 'existing_credentials_require_unlock'),
      );
    }

    final setupResult = await _repository.setupPassword(params.pin);
    if (setupResult.isLeft()) {
      return setupResult;
    }

    final saveResult = await _repository.saveSettings(
      AuthSettings(
        isSetup: true,
        biometricEnabled: params.biometricEnabled,
        appDisplayName: params.appDisplayName,
        appIconKey: params.appIconKey,
        autoLockMinutes: params.autoLockMinutes,
        maxFailedAttempts: params.maxFailedAttempts,
      ),
    );
    if (saveResult.isLeft()) {
      await _repository.discardIncompleteSetup();
      return saveResult;
    }

    final openResult = await _repository.openDatabase();
    if (openResult.isLeft()) {
      await _repository.discardIncompleteSetup();
    }
    return openResult;
  }

  bool _isValidPin(String pin) => RegExp(r'^\d{6}$').hasMatch(pin);
}
