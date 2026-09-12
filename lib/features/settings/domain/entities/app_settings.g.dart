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
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'appLockEnabled': instance.appLockEnabled,
      'privacyModeEnabled': instance.privacyModeEnabled,
      'blurOverlayEnabled': instance.blurOverlayEnabled,
      'lastBackupDate': instance.lastBackupDate?.toIso8601String(),
      'onboardingComplete': instance.onboardingComplete,
    };
