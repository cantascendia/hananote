import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// User-configurable application settings for the profile page.
@freezed
class AppSettings with _$AppSettings {
  /// Creates an [AppSettings].
  const factory AppSettings({
    required bool appLockEnabled,
    required bool privacyModeEnabled,
    required bool blurOverlayEnabled,
    required DateTime? lastBackupDate,
    @Default(false) bool onboardingComplete,
  }) = _AppSettings;

  /// Creates an [AppSettings] from JSON.
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
