import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:hananote/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Repository implementation for profile and settings data.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates a [SettingsRepositoryImpl].
  SettingsRepositoryImpl(this._localDataSource, this._authRepository);

  final SettingsLocalDataSource _localDataSource;
  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() {
    return _guardStorage(() async {
      final storedProfile = await _localDataSource.getUserProfile();
      if (storedProfile == null) {
        return _defaultProfile();
      }

      return storedProfile.normalized();
    });
  }

  @override
  Future<Either<Failure, UserProfile>> saveUserProfile(UserProfile profile) {
    return _guardStorage(() async {
      final normalizedProfile = profile.normalized();
      await _localDataSource.saveUserProfile(normalizedProfile);
      return normalizedProfile;
    });
  }

  @override
  Future<Either<Failure, AppSettings>> getAppSettings() {
    return _guardStorage(() async {
      final stored = await _localDataSource.getAppSettings();
      // Detect upgrades from versions without the onboarding flag:
      // any existing drug means the user has already used the app.
      final activeDrugCount = await _localDataSource.getActiveDrugCount();
      final hasExistingData = activeDrugCount > 0;

      if (stored == null) {
        return _defaultAppSettings()
            .copyWith(hasCompletedOnboarding: hasExistingData);
      }

      if (!stored.hasCompletedOnboarding && hasExistingData) {
        final migrated = stored.copyWith(hasCompletedOnboarding: true);
        await _localDataSource.saveAppSettings(migrated);
        return migrated;
      }
      return stored;
    });
  }

  @override
  Future<Either<Failure, AppSettings>> saveAppSettings(AppSettings settings) {
    return _guardStorage(() async {
      await _localDataSource.saveAppSettings(settings);
      return settings;
    });
  }

  @override
  Future<Either<Failure, int>> getActiveDrugCount() {
    return _guardDatabase(_localDataSource.getActiveDrugCount);
  }

  @override
  Future<Either<Failure, int?>> getInventoryDaysRemaining() {
    return _guardDatabase(_localDataSource.getInventoryDaysRemaining);
  }

  @override
  Future<Either<Failure, void>> wipeAllData() {
    return _authRepository.deleteAllData();
  }

  UserProfile _defaultProfile() {
    return UserProfile.withCalculatedHrtDayCount(
      displayName: '',
    );
  }

  AppSettings _defaultAppSettings() {
    return const AppSettings(
      appLockEnabled: true,
      privacyModeEnabled: false,
      blurOverlayEnabled: true,
      lastBackupDate: null,
    );
  }

  Future<Either<Failure, T>> _guardStorage<T>(
    Future<T> Function() action,
  ) async {
    try {
      return right(await action());
    } catch (error) {
      return left(Failure.storage(message: error.toString()));
    }
  }

  Future<Either<Failure, T>> _guardDatabase<T>(
    Future<T> Function() action,
  ) async {
    try {
      return right(await action());
    } catch (error) {
      return left(Failure.database(message: error.toString()));
    }
  }
}
