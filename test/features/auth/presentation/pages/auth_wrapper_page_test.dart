import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:hananote/features/auth/presentation/pages/auth_wrapper_page.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

SettingsState _loadedState({required bool hasCompletedOnboarding}) {
  final profile = UserProfile.withCalculatedHrtDayCount(
    displayName: '小花',
    hrtStartDate: DateTime(2025, 11, 30),
    today: DateTime(2026, 4, 26),
  );
  final settings = AppSettings(
    appLockEnabled: true,
    privacyModeEnabled: false,
    blurOverlayEnabled: true,
    lastBackupDate: null,
    hasCompletedOnboarding: hasCompletedOnboarding,
    // Disable update check to avoid network calls in tests.
    autoCheckUpdate: false,
  );
  return SettingsState.loaded(
    profile: profile,
    settings: settings,
    activeDrugCount: 1,
    inventoryDaysRemaining: 30,
  );
}

void main() {
  late _MockAuthCubit authCubit;
  late _MockSettingsBloc settingsBloc;

  setUpAll(() {
    registerFallbackValue(const SettingsEvent.loadDashboard());
  });

  setUp(() {
    authCubit = _MockAuthCubit();
    settingsBloc = _MockSettingsBloc();

    when(() => authCubit.state).thenReturn(const AuthState.initial());
    when(() => settingsBloc.state).thenReturn(const SettingsState.initial());
    when(() => settingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: authCubit),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: const AuthWrapperPage(),
          ),
        ),
        GoRoute(
          path: '/today',
          builder: (context, state) => const Scaffold(body: Text('today')),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const Scaffold(
            body: Text('onboarding'),
          ),
        ),
      ],
    );
  }

  testWidgets('settings load failure offers retry without exposing the error',
      (tester) async {
    when(() => authCubit.state).thenReturn(const AuthState.unlocked());
    when(() => settingsBloc.state)
        .thenReturn(const SettingsState.error('sensitive synthetic exception'));
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: buildRouter(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('sensitive synthetic exception'), findsNothing);
    await tester.tap(find.text('Retry'));
    verify(() => settingsBloc.add(const LoadSettingsDashboard())).called(1);
  });

  testWidgets(
    'loads settings then navigates to today when onboarding already done',
    (tester) async {
      final loaded = _loadedState(hasCompletedOnboarding: true);

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable(const [AuthState.unlocked()]),
        initialState: const AuthState.initial(),
      );
      whenListen(
        settingsBloc,
        Stream<SettingsState>.fromIterable([loaded]),
        initialState: const SettingsState.initial(),
      );
      when(() => authCubit.state).thenReturn(const AuthState.unlocked());

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: buildRouter()),
      );
      await tester.pumpAndSettle();

      verify(() => settingsBloc.add(const LoadSettingsDashboard())).called(1);
      expect(find.text('today'), findsOneWidget);
    },
  );

  testWidgets(
    'navigates to onboarding when first launch (hasCompletedOnboarding=false)',
    (tester) async {
      final loaded = _loadedState(hasCompletedOnboarding: false);

      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable(const [AuthState.unlocked()]),
        initialState: const AuthState.initial(),
      );
      whenListen(
        settingsBloc,
        Stream<SettingsState>.fromIterable([loaded]),
        initialState: const SettingsState.initial(),
      );
      when(() => authCubit.state).thenReturn(const AuthState.unlocked());

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: buildRouter()),
      );
      await tester.pumpAndSettle();

      verify(() => settingsBloc.add(const LoadSettingsDashboard())).called(1);
      expect(find.text('onboarding'), findsOneWidget);
      expect(find.text('today'), findsNothing);
    },
  );
}
