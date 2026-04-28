import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/core/platform/file_helper.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/usecases/export_data.dart';
import 'package:hananote/features/settings/domain/usecases/get_profile_dashboard.dart';
import 'package:hananote/features/settings/domain/usecases/update_app_settings.dart';
import 'package:hananote/features/settings/domain/usecases/update_user_profile.dart';
import 'package:hananote/features/settings/domain/usecases/wipe_all_data.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

/// BLoC for managing the settings dashboard state.
@lazySingleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a [SettingsBloc].
  SettingsBloc(
    this._getProfileDashboard,
    this._updateAppSettings,
    this._updateUserProfile,
    this._wipeAllData,
    this._exportData,
  ) : super(const SettingsInitial()) {
    on<LoadSettingsDashboard>(_onLoadDashboard);
    on<ToggleAppLock>(_onToggleAppLock);
    on<TogglePrivacyMode>(_onTogglePrivacyMode);
    on<ToggleBlurOverlay>(_onToggleBlurOverlay);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<UpdateHrtStartDate>(_onUpdateHrtStartDate);
    on<WipeSettingsData>(_onWipeData);
    on<ExportDataEvent>(_onExportData);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ToggleAutoCheckUpdate>(_onToggleAutoCheckUpdate);
    on<SkipVersion>(_onSkipVersion);
    on<ToggleCrashReporting>(_onToggleCrashReporting);
  }

  final GetProfileDashboard _getProfileDashboard;
  final UpdateAppSettings _updateAppSettings;
  final UpdateUserProfile _updateUserProfile;
  final WipeAllData _wipeAllData;
  final ExportData _exportData;

  Future<void> _onLoadDashboard(
    LoadSettingsDashboard event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final failureOrDashboard = await _getProfileDashboard();

    failureOrDashboard.fold(
      (failure) => emit(SettingsError(failureMessage(failure))),
      (dashboard) => emit(
        SettingsLoaded(
          profile: dashboard.profile,
          settings: dashboard.settings,
          activeDrugCount: dashboard.activeDrugCount,
          inventoryDaysRemaining: dashboard.inventoryDaysRemaining,
        ),
      ),
    );
  }

  Future<void> _onToggleAppLock(
    ToggleAppLock event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        appLockEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onTogglePrivacyMode(
    TogglePrivacyMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        privacyModeEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onToggleBlurOverlay(
    ToggleBlurOverlay event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        blurOverlayEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        notificationsEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        darkModeEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        language: event.languageCode,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newProfile = currentState.profile.copyWith(
        displayName: event.name,
      );

      final failureOrProfile = await _updateUserProfile(newProfile);

      failureOrProfile.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedProfile) => emit(
          currentState.copyWith(profile: updatedProfile),
        ),
      );
    }
  }

  Future<void> _onUpdateHrtStartDate(
    UpdateHrtStartDate event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newProfile = currentState.profile.copyWith(
        hrtStartDate: event.date,
      );

      final failureOrProfile = await _updateUserProfile(newProfile);

      failureOrProfile.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedProfile) => emit(
          currentState.copyWith(profile: updatedProfile),
        ),
      );
    }
  }

  Future<void> _onWipeData(
    WipeSettingsData event,
    Emitter<SettingsState> emit,
  ) async {
    final failureOrSuccess = await _wipeAllData();

    failureOrSuccess.fold(
      (failure) => emit(SettingsError(failureMessage(failure))),
      (_) => emit(const SettingsWiped()),
    );
  }

  Future<void> _onToggleAutoCheckUpdate(
    ToggleAutoCheckUpdate event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        autoCheckUpdate: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onSkipVersion(
    SkipVersion event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        skippedVersion: event.version,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onToggleCrashReporting(
    ToggleCrashReporting event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final newSettings = currentState.settings.copyWith(
        crashReportingEnabled: event.enabled,
      );

      final failureOrSettings = await _updateAppSettings(newSettings);

      failureOrSettings.fold(
        (failure) => emit(SettingsError(failureMessage(failure))),
        (updatedSettings) => emit(
          currentState.copyWith(settings: updatedSettings),
        ),
      );
    }
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsState.actionResult(
      actionKey: 'export_in_progress',
      previousState: currentState,
    ));

    final failureOrExport = await _exportData();

    await failureOrExport.fold(
      (failure) async {
        emit(SettingsState.actionResult(
          actionKey: 'export_failed',
          previousState: currentState,
        ));
      },
      (jsonString) async {
        try {
          final fileName =
              'hananote_backup_'
              '${DateTime.now().millisecondsSinceEpoch}.json';
          final filePath = await writeTempFile(fileName, jsonString);

          if (kHasFileSystem) {
            await SharePlus.instance.share(
              ShareParams(
                files: [XFile(filePath)],
                text: 'HanaNote Backup',
              ),
            );
          }
          emit(SettingsState.actionResult(
            actionKey: 'export_success',
            previousState: currentState,
          ));
        } catch (e) {
          emit(SettingsState.actionResult(
            actionKey: 'export_failed',
            previousState: currentState,
          ));
        }
      },
    );

    // After handling the action and showing snackbar, restore visual state
    emit(currentState);
  }
}
