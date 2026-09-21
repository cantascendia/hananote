// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  bool get appLockEnabled => throw _privateConstructorUsedError;
  bool get privacyModeEnabled => throw _privateConstructorUsedError;
  bool get blurOverlayEnabled => throw _privateConstructorUsedError;
  DateTime? get lastBackupDate => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  List<String> get mutedReminderDrugIds => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  bool get darkModeEnabled => throw _privateConstructorUsedError;
  bool get autoCheckUpdate => throw _privateConstructorUsedError;
  String get skippedVersion => throw _privateConstructorUsedError;
  bool get hasCompletedOnboarding => throw _privateConstructorUsedError;
  bool get crashReportingEnabled => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {bool appLockEnabled,
      bool privacyModeEnabled,
      bool blurOverlayEnabled,
      DateTime? lastBackupDate,
      bool notificationsEnabled,
      List<String> mutedReminderDrugIds,
      String language,
      bool darkModeEnabled,
      bool autoCheckUpdate,
      String skippedVersion,
      bool hasCompletedOnboarding,
      bool crashReportingEnabled});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appLockEnabled = null,
    Object? privacyModeEnabled = null,
    Object? blurOverlayEnabled = null,
    Object? lastBackupDate = freezed,
    Object? notificationsEnabled = null,
    Object? mutedReminderDrugIds = null,
    Object? language = null,
    Object? darkModeEnabled = null,
    Object? autoCheckUpdate = null,
    Object? skippedVersion = null,
    Object? hasCompletedOnboarding = null,
    Object? crashReportingEnabled = null,
  }) {
    return _then(_value.copyWith(
      appLockEnabled: null == appLockEnabled
          ? _value.appLockEnabled
          : appLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      privacyModeEnabled: null == privacyModeEnabled
          ? _value.privacyModeEnabled
          : privacyModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      blurOverlayEnabled: null == blurOverlayEnabled
          ? _value.blurOverlayEnabled
          : blurOverlayEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastBackupDate: freezed == lastBackupDate
          ? _value.lastBackupDate
          : lastBackupDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      mutedReminderDrugIds: null == mutedReminderDrugIds
          ? _value.mutedReminderDrugIds
          : mutedReminderDrugIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      darkModeEnabled: null == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCheckUpdate: null == autoCheckUpdate
          ? _value.autoCheckUpdate
          : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      skippedVersion: null == skippedVersion
          ? _value.skippedVersion
          : skippedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
      crashReportingEnabled: null == crashReportingEnabled
          ? _value.crashReportingEnabled
          : crashReportingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool appLockEnabled,
      bool privacyModeEnabled,
      bool blurOverlayEnabled,
      DateTime? lastBackupDate,
      bool notificationsEnabled,
      List<String> mutedReminderDrugIds,
      String language,
      bool darkModeEnabled,
      bool autoCheckUpdate,
      String skippedVersion,
      bool hasCompletedOnboarding,
      bool crashReportingEnabled});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appLockEnabled = null,
    Object? privacyModeEnabled = null,
    Object? blurOverlayEnabled = null,
    Object? lastBackupDate = freezed,
    Object? notificationsEnabled = null,
    Object? mutedReminderDrugIds = null,
    Object? language = null,
    Object? darkModeEnabled = null,
    Object? autoCheckUpdate = null,
    Object? skippedVersion = null,
    Object? hasCompletedOnboarding = null,
    Object? crashReportingEnabled = null,
  }) {
    return _then(_$AppSettingsImpl(
      appLockEnabled: null == appLockEnabled
          ? _value.appLockEnabled
          : appLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      privacyModeEnabled: null == privacyModeEnabled
          ? _value.privacyModeEnabled
          : privacyModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      blurOverlayEnabled: null == blurOverlayEnabled
          ? _value.blurOverlayEnabled
          : blurOverlayEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastBackupDate: freezed == lastBackupDate
          ? _value.lastBackupDate
          : lastBackupDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      mutedReminderDrugIds: null == mutedReminderDrugIds
          ? _value._mutedReminderDrugIds
          : mutedReminderDrugIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      darkModeEnabled: null == darkModeEnabled
          ? _value.darkModeEnabled
          : darkModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoCheckUpdate: null == autoCheckUpdate
          ? _value.autoCheckUpdate
          : autoCheckUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      skippedVersion: null == skippedVersion
          ? _value.skippedVersion
          : skippedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      hasCompletedOnboarding: null == hasCompletedOnboarding
          ? _value.hasCompletedOnboarding
          : hasCompletedOnboarding // ignore: cast_nullable_to_non_nullable
              as bool,
      crashReportingEnabled: null == crashReportingEnabled
          ? _value.crashReportingEnabled
          : crashReportingEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {required this.appLockEnabled,
      required this.privacyModeEnabled,
      required this.blurOverlayEnabled,
      required this.lastBackupDate,
      this.notificationsEnabled = true,
      final List<String> mutedReminderDrugIds = const <String>[],
      this.language = '',
      this.darkModeEnabled = false,
      this.autoCheckUpdate = false,
      this.skippedVersion = '',
      this.hasCompletedOnboarding = false,
      this.crashReportingEnabled = false})
      : _mutedReminderDrugIds = mutedReminderDrugIds;

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  final bool appLockEnabled;
  @override
  final bool privacyModeEnabled;
  @override
  final bool blurOverlayEnabled;
  @override
  final DateTime? lastBackupDate;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  final List<String> _mutedReminderDrugIds;
  @override
  @JsonKey()
  List<String> get mutedReminderDrugIds {
    if (_mutedReminderDrugIds is EqualUnmodifiableListView)
      return _mutedReminderDrugIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mutedReminderDrugIds);
  }

  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool darkModeEnabled;
  @override
  @JsonKey()
  final bool autoCheckUpdate;
  @override
  @JsonKey()
  final String skippedVersion;
  @override
  @JsonKey()
  final bool hasCompletedOnboarding;
  @override
  @JsonKey()
  final bool crashReportingEnabled;

  @override
  String toString() {
    return 'AppSettings(appLockEnabled: $appLockEnabled, privacyModeEnabled: $privacyModeEnabled, blurOverlayEnabled: $blurOverlayEnabled, lastBackupDate: $lastBackupDate, notificationsEnabled: $notificationsEnabled, mutedReminderDrugIds: $mutedReminderDrugIds, language: $language, darkModeEnabled: $darkModeEnabled, autoCheckUpdate: $autoCheckUpdate, skippedVersion: $skippedVersion, hasCompletedOnboarding: $hasCompletedOnboarding, crashReportingEnabled: $crashReportingEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.appLockEnabled, appLockEnabled) ||
                other.appLockEnabled == appLockEnabled) &&
            (identical(other.privacyModeEnabled, privacyModeEnabled) ||
                other.privacyModeEnabled == privacyModeEnabled) &&
            (identical(other.blurOverlayEnabled, blurOverlayEnabled) ||
                other.blurOverlayEnabled == blurOverlayEnabled) &&
            (identical(other.lastBackupDate, lastBackupDate) ||
                other.lastBackupDate == lastBackupDate) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            const DeepCollectionEquality()
                .equals(other._mutedReminderDrugIds, _mutedReminderDrugIds) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.darkModeEnabled, darkModeEnabled) ||
                other.darkModeEnabled == darkModeEnabled) &&
            (identical(other.autoCheckUpdate, autoCheckUpdate) ||
                other.autoCheckUpdate == autoCheckUpdate) &&
            (identical(other.skippedVersion, skippedVersion) ||
                other.skippedVersion == skippedVersion) &&
            (identical(other.hasCompletedOnboarding, hasCompletedOnboarding) ||
                other.hasCompletedOnboarding == hasCompletedOnboarding) &&
            (identical(other.crashReportingEnabled, crashReportingEnabled) ||
                other.crashReportingEnabled == crashReportingEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      appLockEnabled,
      privacyModeEnabled,
      blurOverlayEnabled,
      lastBackupDate,
      notificationsEnabled,
      const DeepCollectionEquality().hash(_mutedReminderDrugIds),
      language,
      darkModeEnabled,
      autoCheckUpdate,
      skippedVersion,
      hasCompletedOnboarding,
      crashReportingEnabled);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {required final bool appLockEnabled,
      required final bool privacyModeEnabled,
      required final bool blurOverlayEnabled,
      required final DateTime? lastBackupDate,
      final bool notificationsEnabled,
      final List<String> mutedReminderDrugIds,
      final String language,
      final bool darkModeEnabled,
      final bool autoCheckUpdate,
      final String skippedVersion,
      final bool hasCompletedOnboarding,
      final bool crashReportingEnabled}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  bool get appLockEnabled;
  @override
  bool get privacyModeEnabled;
  @override
  bool get blurOverlayEnabled;
  @override
  DateTime? get lastBackupDate;
  @override
  bool get notificationsEnabled;
  @override
  List<String> get mutedReminderDrugIds;
  @override
  String get language;
  @override
  bool get darkModeEnabled;
  @override
  bool get autoCheckUpdate;
  @override
  String get skippedVersion;
  @override
  bool get hasCompletedOnboarding;
  @override
  bool get crashReportingEnabled;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
