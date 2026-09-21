import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:hananote/features/settings/presentation/pages/settings_detail_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  late _MockSettingsBloc settingsBloc;

  final loadedState = SettingsState.loaded(
    profile: UserProfile(
      displayName: '小花',
      hrtDayCount: 100,
      hrtStartDate: DateTime(2026),
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
  });

  setUp(() {
    settingsBloc = _MockSettingsBloc();
    when(() => settingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildApp(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<SettingsBloc>.value(
            value: settingsBloc,
            child: child,
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  testWidgets('shows loading indicator when settings are not loaded', (
    tester,
  ) async {
    when(() => settingsBloc.state).thenReturn(const SettingsState.initial());

    await tester.pumpWidget(buildApp(const SettingsDetailPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays user displayName when settings are loaded', (
    tester,
  ) async {
    when(() => settingsBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(buildApp(const SettingsDetailPage()));

    expect(find.text('小花'), findsOneWidget);
  });

  testWidgets('displays HRT start date when settings are loaded', (
    tester,
  ) async {
    when(() => settingsBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(buildApp(const SettingsDetailPage()));
    await tester.pumpAndSettle();

    // The date format depends on locale; just ensure it renders
    expect(find.textContaining('2026'), findsWidgets);
  });
}
