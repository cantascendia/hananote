import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';

void main() {
  group('UserProfile.withCalculatedHrtDayCount', () {
    test('derives hrtDayCount from the start date', () {
      final profile = UserProfile.withCalculatedHrtDayCount(
        displayName: '小花',
        hrtStartDate: DateTime(2025, 11, 30),
        today: DateTime(2026, 3, 27),
      );

      expect(profile.hrtDayCount, 117);
    });

    test('clamps hrtDayCount to zero for a future start date', () {
      final profile = UserProfile.withCalculatedHrtDayCount(
        displayName: '小花',
        hrtStartDate: DateTime(2026, 4),
        today: DateTime(2026, 3, 27),
      );

      expect(profile.hrtDayCount, 0);
    });
  });

  group('UserProfile.normalized', () {
    test('recalculates hrtDayCount from hrtStartDate', () {
      final profile = UserProfile(
        displayName: '小花',
        hrtDayCount: 0,
        hrtStartDate: DateTime(2025, 11, 30),
      );

      final normalized = profile.normalized(today: DateTime(2026, 3, 27));

      expect(normalized.hrtDayCount, 117);
      expect(normalized.displayName, profile.displayName);
      expect(normalized.hrtStartDate, profile.hrtStartDate);
    });
  });

  test('test: unknown HRT date has zero derived days without a fallback date',
      () {
    final profile = UserProfile.withCalculatedHrtDayCount(
      displayName: '',
      today: DateTime(2026, 9, 22),
    );

    expect(profile.hrtStartDate, isNull);
    expect(profile.hrtDayCount, 0);
    expect(profile.normalized(today: DateTime(2027)).hrtDayCount, 0);
  });
}
