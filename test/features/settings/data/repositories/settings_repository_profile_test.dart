import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/features/auth/domain/repositories/auth_repository.dart';
import 'package:hananote/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:hananote/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:mocktail/mocktail.dart';

class _LocalData extends Mock implements SettingsLocalDataSource {}

class _AuthRepository extends Mock implements AuthRepository {}

void main() {
  late _LocalData localData;
  late SettingsRepositoryImpl repository;

  setUp(() {
    localData = _LocalData();
    repository = SettingsRepositoryImpl(localData, _AuthRepository());
  });

  test('test: absent profile never invents name or HRT start date', () async {
    when(() => localData.getUserProfile()).thenAnswer((_) async => null);

    final result = await repository.getUserProfile();
    final profile = result.getRight().toNullable()!;
    expect(profile.displayName, isEmpty);
    expect(profile.hrtStartDate, isNull);
    expect(profile.hrtDayCount, 0);
  });

  test('test: previously stored HRT date remains readable', () async {
    final stored = UserProfile(
      displayName: 'existing name',
      hrtDayCount: 0,
      hrtStartDate: DateTime(2025, 11, 30),
    );
    when(() => localData.getUserProfile()).thenAnswer((_) async => stored);

    final result = await repository.getUserProfile();
    final profile = result.getRight().toNullable()!;
    expect(profile.displayName, 'existing name');
    expect(profile.hrtStartDate, DateTime(2025, 11, 30));
    expect(profile.hrtDayCount, greaterThan(0));
  });
}
