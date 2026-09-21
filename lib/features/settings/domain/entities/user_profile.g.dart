// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      displayName: json['displayName'] as String,
      hrtDayCount: (json['hrtDayCount'] as num).toInt(),
      hrtStartDate: json['hrtStartDate'] == null
          ? null
          : DateTime.parse(json['hrtStartDate'] as String),
      avatarPath: json['avatarPath'] as String?,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'hrtDayCount': instance.hrtDayCount,
      'hrtStartDate': instance.hrtStartDate?.toIso8601String(),
      'avatarPath': instance.avatarPath,
    };
