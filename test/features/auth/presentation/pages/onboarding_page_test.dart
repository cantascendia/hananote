import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/auth/presentation/pages/onboarding_page.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _MockMedicationRepository extends Mock implements MedicationRepository {}

SettingsState _loaded({bool completed = false}) => SettingsState.loaded(
      profile: UserProfile(
          displayName: '', hrtDayCount: 0, hrtStartDate: DateTime(2026)),
      settings: AppSettings(
          appLockEnabled: false,
          privacyModeEnabled: false,
          blurOverlayEnabled: false,
          lastBackupDate: null,
          hasCompletedOnboarding: completed),
      activeDrugCount: 0,
      inventoryDaysRemaining: null,
    );

void main() {
  late _MockSettingsBloc bloc;
  late _MockMedicationRepository medication;
  late StreamController<SettingsState> controller;
  late SettingsState current;
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(const MarkOnboardingComplete());
    registerFallbackValue(Drug(
        id: 'fallback',
        name: 'fallback',
        genericName: '',
        category: DrugCategory.estrogen,
        administrationRoute: AdministrationRoute.oral,
        defaultDosageUnit: DosageUnit.mg,
        isActive: true,
        createdAt: DateTime(2026)));
  });

  setUp(() {
    bloc = _MockSettingsBloc();
    medication = _MockMedicationRepository();
    controller = StreamController<SettingsState>.broadcast();
    current = _loaded();
    when(() => bloc.state).thenAnswer((_) => current);
    when(() => bloc.stream).thenAnswer((_) => controller.stream);
    when(() => bloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.single;
      if (event is MarkOnboardingComplete) {
        scheduleMicrotask(() {
          current = _loaded(completed: true);
          controller.add(current);
        });
      }
    });
    getIt.registerSingleton<MedicationRepository>(medication);
    router = GoRouter(initialLocation: '/onboarding', routes: [
      GoRoute(
          path: '/onboarding',
          builder: (_, __) => BlocProvider<SettingsBloc>.value(
              value: bloc, child: const OnboardingPage())),
      GoRoute(
          path: '/today',
          builder: (_, __) => const Scaffold(body: Text('local today'))),
      GoRoute(
          path: '/auth',
          builder: (_, __) => const Scaffold(body: Text('cloud auth'))),
    ]);
  });

  tearDown(() async {
    router.dispose();
    await controller.close();
    await getIt.unregister<MedicationRepository>();
  });

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
    final next = find.text('Next');
    await tester.tap(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
  }

  testWidgets('test: local onboarding navigates to today', (tester) async {
    await show(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('local today'), findsOneWidget);
    verify(() => bloc.add(any(that: isA<MarkOnboardingComplete>()))).called(1);
  });

  testWidgets('test: save failure stays on onboarding', (tester) async {
    when(() => bloc.add(any())).thenAnswer((invocation) {
      if (invocation.positionalArguments.single is MarkOnboardingComplete) {
        scheduleMicrotask(() {
          current = const SettingsState.error('save failed');
          controller.add(current);
        });
      }
    });
    await show(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('local today'), findsNothing);
  });

  testWidgets('test: double tap does not add duplicate drug', (tester) async {
    when(() => medication.addDrug(any())).thenAnswer((invocation) async =>
        right(invocation.positionalArguments.single as Drug));
    await show(tester);
    await tester.enterText(find.byType(TextField).last, 'synthetic');
    final done = find.text('Get Started');
    await tester.tap(done);
    await tester.tap(done);
    await tester.pumpAndSettle();
    verify(() => medication.addDrug(any())).called(1);
  });
}
