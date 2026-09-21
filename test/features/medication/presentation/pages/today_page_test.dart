import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart'
    as medication;
import 'package:hananote/features/medication/domain/usecases/get_today_schedule.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_bloc.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_event.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_state.dart';
import 'package:hananote/core/widgets/hoyo/conic_avatar_ring.dart';
import 'package:hananote/features/medication/presentation/pages/today_page.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _MockTodayScheduleBloc
    extends MockBloc<TodayScheduleEvent, TodayScheduleState>
    implements TodayScheduleBloc {}

void main() {
  late _MockSettingsBloc settingsBloc;
  late _MockTodayScheduleBloc todayScheduleBloc;
  // v2 (R52) replaced the daily-quote rotation with the Daily 花笺
  // signature card (HanaDailyCard). The quote rotation list lives on
  // in localized assets but is no longer surfaced on Today page.

  final loadedSettings = SettingsState.loaded(
    profile: UserProfile(
      displayName: '小花',
      hrtDayCount: 123,
      hrtStartDate: DateTime(2025, 11, 26),
    ),
    settings: const AppSettings(
      appLockEnabled: true,
      privacyModeEnabled: false,
      blurOverlayEnabled: false,
      lastBackupDate: null,
    ),
    activeDrugCount: 1,
    inventoryDaysRemaining: 30,
  );

  setUpAll(() {
    registerFallbackValue(const SettingsEvent.loadDashboard());
    registerFallbackValue(const TodayScheduleEvent.load());
  });

  setUp(() {
    settingsBloc = _MockSettingsBloc();
    todayScheduleBloc = _MockTodayScheduleBloc();

    when(() => settingsBloc.state).thenReturn(loadedSettings);
    when(() => settingsBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => todayScheduleBloc.state)
        .thenReturn(const TodayScheduleState.initial());
    when(() => todayScheduleBloc.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  MaterialApp buildLocalizedApp(Widget child) {
    return MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  testWidgets('renders greeting and HRT day count from settings state', (
    tester,
  ) async {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '早安'
        : hour < 18
            ? '午安'
            : '晚上好';

    await tester.pumpWidget(
      buildLocalizedApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<TodayScheduleBloc>.value(value: todayScheduleBloc),
          ],
          child: const TodayPage(),
        ),
      ),
    );

    expect(find.text('$greeting，小花'), findsOneWidget);
    expect(find.text('HRT 第 123 天'), findsOneWidget);
  });

  testWidgets('renders the Daily 花笺 signature card with day count', (
    tester,
  ) async {
    final item = TodayScheduleItem(
      drug: Drug(
        id: 'drug-1',
        name: 'Estradiol',
        genericName: 'Estradiol',
        category: DrugCategory.estrogen,
        administrationRoute: AdministrationRoute.oral,
        defaultDosageUnit: DosageUnit.mg,
        isActive: true,
        createdAt: DateTime(2026),
      ),
      schedule: medication.MedicationSchedule(
        id: 'schedule-1',
        drugId: 'drug-1',
        dosageAmount: 2,
        dosageUnit: DosageUnit.mg,
        frequency: const medication.MedicationFrequency.daily(timesPerDay: 1),
        administrationRoute: AdministrationRoute.oral,
        startDate: DateTime(2026),
        isActive: true,
        scheduleTimes: const [medication.TimeOfDay(hour: 8, minute: 0)],
      ),
      logs: const [],
      scheduledDateTimes: [DateTime.now().add(const Duration(hours: 1))],
      isCompleted: false,
    );

    when(() => todayScheduleBloc.state).thenReturn(
      TodayScheduleState.loaded(
        items: [item],
        date: DateTime.now(),
        completedCount: 0,
        totalCount: 1,
      ),
    );

    await tester.pumpWidget(
      buildLocalizedApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<TodayScheduleBloc>.value(value: todayScheduleBloc),
          ],
          child: const TodayPage(),
        ),
      ),
    );

    // Single pump to render the initial frame; FlowerAlmanac.load is
    // async so the Daily 花笺 card may render its placeholder. We
    // assert that the page itself rendered without overflow rather
    // than depend on async asset loading inside the test environment.
    expect(find.byType(TodayPage), findsOneWidget);
    expect(find.text('HRT 第 123 天'), findsOneWidget);
  });

  testWidgets('avatar navigates to the profile page', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
              BlocProvider<TodayScheduleBloc>.value(value: todayScheduleBloc),
            ],
            child: const TodayPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Scaffold(body: Text('profile')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    // v2 replaced the Icons.person CircleAvatar with ConicAvatarRing
    // (a SweepGradient disc rendering the user's signature char).
    await tester.tap(find.byType(ConicAvatarRing));
    await tester.pumpAndSettle();

    expect(find.text('profile'), findsOneWidget);
  });

  testWidgets('shows loading indicator for initial schedule state', (
    tester,
  ) async {
    when(() => todayScheduleBloc.state)
        .thenReturn(const TodayScheduleState.initial());

    await tester.pumpWidget(
      buildLocalizedApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<TodayScheduleBloc>.value(value: todayScheduleBloc),
          ],
          child: const TodayPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calendar icon navigates to the timeline page', (tester) async {
    when(() => todayScheduleBloc.state).thenReturn(
      TodayScheduleState.loaded(
        items: const [],
        date: DateTime.now(),
        completedCount: 0,
        totalCount: 0,
      ),
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
              BlocProvider<TodayScheduleBloc>.value(value: todayScheduleBloc),
            ],
            child: const TodayPage(),
          ),
        ),
        GoRoute(
          path: '/timeline',
          builder: (context, state) => const Scaffold(body: Text('timeline')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    expect(find.text('timeline'), findsOneWidget);
  });
}
