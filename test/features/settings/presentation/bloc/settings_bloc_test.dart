import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/domain/usecases/export_data.dart';
import 'package:hananote/features/settings/domain/usecases/generate_pdf_report.dart';
import 'package:hananote/features/settings/domain/usecases/get_profile_dashboard.dart';
import 'package:hananote/features/settings/domain/usecases/import_data.dart';
import 'package:hananote/features/settings/domain/usecases/update_app_settings.dart';
import 'package:hananote/features/settings/domain/usecases/update_user_profile.dart';
import 'package:hananote/features/settings/domain/usecases/wipe_all_data.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfileDashboard extends Mock implements GetProfileDashboard {}

class _MockUpdateAppSettings extends Mock implements UpdateAppSettings {}

class _MockUpdateUserProfile extends Mock implements UpdateUserProfile {}

class _MockWipeAllData extends Mock implements WipeAllData {}

class _MockExportData extends Mock implements ExportData {}

class _MockGeneratePdfReport extends Mock implements GeneratePdfReport {}

class _MockImportData extends Mock implements ImportData {}

void main() {
  late _MockGetProfileDashboard getProfileDashboard;
  late _MockUpdateAppSettings updateAppSettings;
  late _MockUpdateUserProfile updateUserProfile;
  late _MockWipeAllData wipeAllData;
  late _MockExportData exportData;
  late _MockGeneratePdfReport generatePdfReport;
  late _MockImportData importData;

  final profile = UserProfile.withCalculatedHrtDayCount(
    displayName: '小花',
    hrtStartDate: DateTime(2025, 11, 30),
    today: DateTime(2026, 3, 27),
  );
  const settings = AppSettings(
    appLockEnabled: true,
    privacyModeEnabled: false,
    blurOverlayEnabled: true,
    lastBackupDate: null,
  );

  SettingsBloc buildBloc() => SettingsBloc(
        getProfileDashboard,
        updateAppSettings,
        updateUserProfile,
        wipeAllData,
        exportData,
        generatePdfReport,
        importData,
      );

  SettingsState buildLoadedState() {
    return SettingsState.loaded(
      profile: profile,
      settings: settings,
      activeDrugCount: 2,
      inventoryDaysRemaining: 18,
    );
  }

  setUpAll(() {
    registerFallbackValue(settings);
    registerFallbackValue(profile);
  });

  setUp(() {
    getProfileDashboard = _MockGetProfileDashboard();
    updateAppSettings = _MockUpdateAppSettings();
    updateUserProfile = _MockUpdateUserProfile();
    wipeAllData = _MockWipeAllData();
    exportData = _MockExportData();
    generatePdfReport = _MockGeneratePdfReport();
    importData = _MockImportData();
  });

  test('initial state is SettingsInitial', () {
    expect(buildBloc().state, isA<SettingsInitial>());
  });

  group('LoadSettingsDashboard', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits [loading, loaded] when dashboard data loads successfully',
      build: buildBloc,
      setUp: () {
        when(() => getProfileDashboard()).thenAnswer(
          (_) async => right(
            (
              profile: profile,
              settings: settings,
              activeDrugCount: 2,
              inventoryDaysRemaining: 18,
            ),
          ),
        );
      },
      act: (bloc) => bloc.add(const SettingsEvent.loadDashboard()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>()
            .having((state) => state.profile, 'profile', profile)
            .having((state) => state.settings, 'settings', settings)
            .having((state) => state.activeDrugCount, 'activeDrugCount', 2)
            .having(
              (state) => state.inventoryDaysRemaining,
              'inventoryDaysRemaining',
              18,
            ),
      ],
      verify: (_) {
        verify(() => getProfileDashboard()).called(1);
      },
    );
  });

  group('ToggleAppLock', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates settings when app lock toggle succeeds',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => updateAppSettings(any())).thenAnswer(
          (_) async => right(
            settings.copyWith(appLockEnabled: false),
          ),
        );
      },
      act: (bloc) =>
          bloc.add(const SettingsEvent.toggleAppLock(enabled: false)),
      expect: () => [
        isA<SettingsLoaded>()
            .having(
              (state) => state.settings.appLockEnabled,
              'appLockEnabled',
              false,
            )
            .having((state) => state.profile, 'profile', profile)
            .having((state) => state.activeDrugCount, 'activeDrugCount', 2),
      ],
      verify: (_) {
        verify(
          () => updateAppSettings(
            settings.copyWith(appLockEnabled: false),
          ),
        ).called(1);
      },
    );
  });

  group('UpdateDisplayName', () {
    final updatedProfile = profile.copyWith(displayName: 'NewName');

    blocTest<SettingsBloc, SettingsState>(
      'updates profile when name update succeeds',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => updateUserProfile(any())).thenAnswer(
          (_) async => right(updatedProfile),
        );
      },
      act: (bloc) =>
          bloc.add(const SettingsEvent.updateDisplayName(name: 'NewName')),
      expect: () => [
        isA<SettingsLoaded>()
            .having(
              (state) => state.profile.displayName,
              'displayName',
              'NewName',
            )
            .having((state) => state.settings, 'settings', settings),
      ],
      verify: (_) {
        verify(() => updateUserProfile(updatedProfile)).called(1);
      },
    );
  });

  group('UpdateHrtStartDate', () {
    final newDate = DateTime(2025);
    final updatedProfile = profile.copyWith(hrtStartDate: newDate);

    blocTest<SettingsBloc, SettingsState>(
      'updates profile when HRT start date update succeeds',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => updateUserProfile(any())).thenAnswer(
          (_) async => right(updatedProfile),
        );
      },
      act: (bloc) => bloc.add(SettingsEvent.updateHrtStartDate(date: newDate)),
      expect: () => [
        isA<SettingsLoaded>()
            .having(
              (state) => state.profile.hrtStartDate,
              'hrtStartDate',
              newDate,
            )
            .having((state) => state.settings, 'settings', settings),
      ],
      verify: (_) {
        verify(() => updateUserProfile(updatedProfile)).called(1);
      },
    );
  });

  group('WipeSettingsData', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits wiped when data wipe succeeds',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => wipeAllData()).thenAnswer((_) async => right(null));
      },
      act: (bloc) => bloc.add(const SettingsEvent.wipeData()),
      expect: () => [isA<SettingsWiped>()],
      verify: (_) {
        verify(() => wipeAllData()).called(1);
      },
    );
  });

  group('onboarding persistence', () {
    final startDate = DateTime(2026, 1, 2);
    final updatedProfile = profile.copyWith(
      displayName: 'Test',
      hrtStartDate: startDate,
    );

    blocTest<SettingsBloc, SettingsState>(
      'saves both profile fields before marking onboarding complete',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => updateUserProfile(any())).thenAnswer(
          (_) async => right(updatedProfile),
        );
        when(() => updateAppSettings(any())).thenAnswer(
          (invocation) async => right(
            invocation.positionalArguments.first as AppSettings,
          ),
        );
      },
      act: (bloc) => bloc.add(MarkOnboardingComplete(
        displayName: 'Test',
        hrtStartDate: startDate,
      )),
      expect: () => [
        isA<SettingsLoaded>()
            .having((s) => s.profile, 'profile', updatedProfile)
            .having((s) => s.settings.hasCompletedOnboarding, 'complete', true),
      ],
      verify: (_) => verifyInOrder([
        () => updateUserProfile(updatedProfile),
        () => updateAppSettings(any()),
      ]),
    );

    blocTest<SettingsBloc, SettingsState>(
      'failed profile save leaves onboarding incomplete and allows retry',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () => when(() => updateUserProfile(any())).thenAnswer(
        (_) async => left(const Failure.storage(message: 'synthetic failure')),
      ),
      act: (bloc) =>
          bloc.add(const MarkOnboardingComplete(displayName: 'Test')),
      expect: () => [isA<SettingsError>(), buildLoadedState()],
      verify: (_) => verifyNever(() => updateAppSettings(any())),
    );
  });

  group('failure handling', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits error when dashboard loading fails',
      build: buildBloc,
      setUp: () {
        when(() => getProfileDashboard()).thenAnswer(
          (_) async => left(const Failure.storage(message: 'load failed')),
        );
      },
      act: (bloc) => bloc.add(const SettingsEvent.loadDashboard()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsError>()
            .having((state) => state.message, 'message', 'load failed'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits error when wiping data fails',
      build: buildBloc,
      seed: buildLoadedState,
      setUp: () {
        when(() => wipeAllData()).thenAnswer(
          (_) async => left(const Failure.storage(message: 'wipe failed')),
        );
      },
      act: (bloc) => bloc.add(const SettingsEvent.wipeData()),
      expect: () => [
        isA<SettingsError>()
            .having((state) => state.message, 'message', 'wipe failed'),
      ],
    );
  });
}
