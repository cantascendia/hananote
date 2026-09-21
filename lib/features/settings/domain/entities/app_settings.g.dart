// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      appLockEnabled: json['appLockEnabled'] as bool,
      privacyModeEnabled: json['privacyModeEnabled'] as bool,
      blurOverlayEnabled: json['blurOverlayEnabled'] as bool,
      lastBackupDate: json['lastBackupDate'] == null
          ? null
          : DateTime.parse(json['lastBackupDate'] as String),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      mutedReminderDrugIds: (json['mutedReminderDrugIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      language: json['language'] as String? ?? '',
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? false,
      skippedVersion: json['skippedVersion'] as String? ?? '',
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'appLockEnabled': instance.appLockEnabled,
      'privacyModeEnabled': instance.privacyModeEnabled,
      'blurOverlayEnabled': instance.blurOverlayEnabled,
      'lastBackupDate': instance.lastBackupDate?.toIso8601String(),
      'notificationsEnabled': instance.notificationsEnabled,
      'mutedReminderDrugIds': instance.mutedReminderDrugIds,
      'language': instance.language,
      'darkModeEnabled': instance.darkModeEnabled,
      'autoCheckUpdate': instance.autoCheckUpdate,
      'skippedVersion': instance.skippedVersion,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'crashReportingEnabled': instance.crashReportingEnabled,
    };
