import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/domain/entities/auth_settings.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:hananote/features/auth/domain/usecases/setup_app.dart';
import 'package:hananote/features/auth/domain/usecases/unlock_app.dart';
import 'package:hananote/features/auth/domain/usecases/wipe_data.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:injectable/injectable.dart';

/// Drives the app security flow from startup through unlock.
@injectable
class AuthCubit extends Cubit<AuthState> {
  /// Creates [AuthCubit].
  AuthCubit(
    this._repository,
    this._setupApp,
    this._unlockApp,
    this._wipeData,
  ) : super(const AuthState.initial());

  final AuthRepository _repository;
  final SetupApp _setupApp;
  final UnlockApp _unlockApp;
  final WipeData _wipeData;

  AuthSettings? _settings;
  var _failedAttempts = 0;

  /// Immediately hides an unlocked session when the app is backgrounded.
  /// The in-memory key is retained for optional warm-session biometrics.
  void lockSession() {
    if (state is! AuthUnlocked) return;
    emit(const AuthState.locked(biometricAvailable: false));
    unawaited(_refreshBiometricAvailability());
  }

  Future<void> _refreshBiometricAvailability() async {
    final lockedState = await _buildLockedState();
    if (!isClosed && state is AuthLocked) emit(lockedState);
  }

  /// Determines whether setup or unlock is needed on startup.
  Future<void> checkAuthStatus() async {
    final result = await _repository.getSettings();
    await result.fold(
      (failure) async => _emitErrorWithFallback(
        failureMessage(failure),
        const AuthState.locked(biometricAvailable: false),
      ),
      (settings) async {
        _settings = settings;
        _failedAttempts = 0;
        if (!settings.isSetup) {
          emit(const AuthState.needsSetup());
          return;
        }
        emit(await _buildLockedState());
      },
    );
  }

  /// Handles initial PIN setup.
  Future<void> setupPin(
    String pin,
    String confirmPin, {
    bool biometricEnabled = false,
  }) async {
    if (pin != confirmPin) {
      _emitErrorWithFallback(
        '\u4E24\u6B21\u8F93\u5165\u7684\u5BC6\u7801\u4E0D\u4E00\u81F4',
        const AuthState.needsSetup(),
      );
      return;
    }

    emit(const AuthState.unlocking());
    final result = await _setupApp(
      SetupAppParams(
        pin: pin,
        biometricEnabled: biometricEnabled,
      ),
    );

    await result.fold(
      (failure) async => _emitErrorWithFallback(
        failureMessage(failure),
        const AuthState.needsSetup(),
      ),
      (_) async {
        final settingsResult = await _repository.getSettings();
        _settings = settingsResult.getOrElse(
          (_) => const AuthSettings(
            isSetup: true,
            biometricEnabled: false,
            appDisplayName: 'HanaNote',
            appIconKey: 'default',
            autoLockMinutes: 0,
            maxFailedAttempts: 0,
          ),
        );
        emit(const AuthState.unlocked());
      },
    );
  }

  /// Unlocks the app with [pin].
  Future<void> unlock(String pin) async {
    emit(const AuthState.unlocking());
    final result = await _unlockApp(pin);
    await result.fold(
      (failure) async => _emitErrorWithFallback(
        failureMessage(failure),
        await _buildLockedState(),
      ),
      (isUnlocked) async {
        if (isUnlocked) {
          _failedAttempts = 0;
          emit(const AuthState.unlocked());
          return;
        }

        _failedAttempts++;
        final maxAttempts = _settings?.maxFailedAttempts ?? 0;
        if (maxAttempts > 0 && _failedAttempts >= maxAttempts) {
          await wipeData();
          return;
        }

        _emitErrorWithFallback(
          '\u5BC6\u7801\u9519\u8BEF',
          await _buildLockedState(),
        );
      },
    );
  }

  /// Unlocks the app with biometrics when enabled.
  Future<void> unlockBiometric() async {
    emit(const AuthState.unlocking());
    final authResult = await _repository.authenticateBiometric();
    await authResult.fold(
      (failure) async => _emitErrorWithFallback(
        failureMessage(failure),
        await _buildLockedState(),
      ),
      (authenticated) async {
        if (!authenticated) {
          emit(await _buildLockedState());
          return;
        }

        final openResult = await _repository.openDatabase();
        openResult.fold(
          (failure) => _emitErrorWithFallback(
            failureMessage(failure),
            const AuthState.locked(biometricAvailable: false),
          ),
          (_) => emit(const AuthState.unlocked()),
        );
      },
    );
  }

  /// Wipes all secure app data.
  Future<void> wipeData() async {
    final result = await _wipeData();
    result.fold(
      (failure) => _emitErrorWithFallback(
        failureMessage(failure),
        const AuthState.needsSetup(),
      ),
      (_) {
        _settings = null;
        _failedAttempts = 0;
        emit(const AuthState.wiped());
      },
    );
  }

  Future<AuthState> _buildLockedState() async {
    final settings = _settings;
    if (settings == null) {
      return const AuthState.locked(biometricAvailable: false);
    }
    if (!settings.isSetup) {
      return const AuthState.needsSetup();
    }

    final biometricResult = await _repository.isBiometricAvailable();
    final biometricAvailable =
        settings.biometricEnabled && biometricResult.getOrElse((_) => false);
    return AuthState.locked(biometricAvailable: biometricAvailable);
  }

  void _emitErrorWithFallback(String message, AuthState fallback) {
    emit(AuthState.error(message: message));
    Future.microtask(() {
      if (!isClosed) emit(fallback);
    });
  }
}
