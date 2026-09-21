import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Profile information shown on the settings dashboard.
@freezed
class UserProfile with _$UserProfile {
  /// Creates a [UserProfile].
  const factory UserProfile({
    required String displayName,
    required int hrtDayCount,
    DateTime? hrtStartDate,
    String? avatarPath,
  }) = _UserProfile;

  const UserProfile._();

  /// Creates a [UserProfile] with [hrtDayCount] derived from [hrtStartDate].
  factory UserProfile.withCalculatedHrtDayCount({
    required String displayName,
    DateTime? hrtStartDate,
    String? avatarPath,
    DateTime? today,
  }) {
    return UserProfile(
      displayName: displayName,
      hrtDayCount: _calculateHrtDayCount(hrtStartDate, today: today),
      hrtStartDate: hrtStartDate,
      avatarPath: avatarPath,
    );
  }

  /// Creates a [UserProfile] from JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Returns a copy with [hrtDayCount] recalculated from [hrtStartDate].
  UserProfile normalized({DateTime? today}) {
    return copyWith(
      hrtDayCount: _calculateHrtDayCount(hrtStartDate, today: today),
    );
  }

  static int _calculateHrtDayCount(
    DateTime? hrtStartDate, {
    DateTime? today,
  }) {
    if (hrtStartDate == null) return 0;
    final currentDay = today ?? DateTime.now();
    final normalizedStartDate = DateTime(
      hrtStartDate.year,
      hrtStartDate.month,
      hrtStartDate.day,
    );
    final normalizedToday = DateTime(
      currentDay.year,
      currentDay.month,
      currentDay.day,
    );
    final difference = normalizedToday.difference(normalizedStartDate).inDays;
    return difference < 0 ? 0 : difference;
  }
}
