import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.freezed.dart';

/// Events for the SettingsBloc.
@freezed
sealed class SettingsEvent with _$SettingsEvent {
  /// Loads the settings dashboard data.
  const factory SettingsEvent.loadDashboard() = LoadSettingsDashboard;

  /// Toggles the app lock setting.
  const factory SettingsEvent.toggleAppLock({required bool enabled}) =
      ToggleAppLock;

  /// Toggles the privacy mode setting.
  const factory SettingsEvent.togglePrivacyMode({required bool enabled}) =
      TogglePrivacyMode;

  /// Toggles the blur overlay setting.
  const factory SettingsEvent.toggleBlurOverlay({required bool enabled}) =
      ToggleBlurOverlay;

  /// Updates the user's display name.
  const factory SettingsEvent.updateDisplayName({required String name}) =
      UpdateDisplayName;

  /// Updates the user's HRT start date.
  const factory SettingsEvent.updateHrtStartDate({required DateTime date}) =
      UpdateHrtStartDate;

  /// Wipes all protected application data.
  const factory SettingsEvent.wipeData() = WipeSettingsData;

  /// Toggles the notifications enabled setting.
  const factory SettingsEvent.toggleNotifications({required bool enabled}) =
      ToggleNotifications;

  /// Exports local data to a JSON file.
  const factory SettingsEvent.exportData() = ExportDataEvent;

  /// Changes the app display language.
  const factory SettingsEvent.changeLanguage({required String languageCode}) =
      ChangeLanguage;

  /// Toggles the dark mode setting.
  const factory SettingsEvent.toggleDarkMode({required bool enabled}) =
      ToggleDarkMode;

  /// Toggles auto-check for updates setting.
  const factory SettingsEvent.toggleAutoCheckUpdate({required bool enabled}) =
      ToggleAutoCheckUpdate;

  /// Sets the version the user chose to skip.
  const factory SettingsEvent.skipVersion({required String version}) =
      SkipVersion;

  /// Toggles crash reporting (opt-in, privacy-first).
  const factory SettingsEvent.toggleCrashReporting({required bool enabled}) =
      ToggleCrashReporting;
}
