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

  /// Exports local data to a JSON file.
  const factory SettingsEvent.exportData() = ExportDataEvent;

  /// Imports data from a backup JSON file.
  const factory SettingsEvent.importData() = ImportDataEvent;

  /// Generates a PDF health report.
  const factory SettingsEvent.generatePdf() = GeneratePdfEvent;

  /// Marks onboarding as complete.
  const factory SettingsEvent.markOnboardingComplete() =
      MarkOnboardingComplete;
}
