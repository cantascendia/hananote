import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/auth_redirect.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/presentation/main_shell.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/features/auth/presentation/pages/auth_wrapper_page.dart';
import 'package:hananote/features/auth/presentation/pages/onboarding_page.dart';
import 'package:hananote/core/auth/auth_service.dart';
import 'package:hananote/features/cloud_auth/presentation/bloc/auth_bloc.dart';
import 'package:hananote/features/cloud_auth/presentation/pages/account_page.dart';
import 'package:hananote/features/cloud_auth/presentation/pages/auth_landing_page.dart';
import 'package:hananote/features/cloud_auth/presentation/pages/sign_in_page.dart';
import 'package:hananote/features/cloud_auth/presentation/pages/sign_up_page.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_bloc.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_event.dart';
import 'package:hananote/features/blood_test/presentation/pages/blood_test_edit_page.dart';
import 'package:hananote/features/blood_test/presentation/pages/data_page.dart';
import 'package:hananote/features/journal/presentation/bloc/record_bloc.dart';
import 'package:hananote/features/journal/presentation/bloc/record_event.dart';
import 'package:hananote/features/journal/presentation/pages/journal_edit_page.dart';
import 'package:hananote/features/journal/presentation/pages/record_page.dart';
import 'package:hananote/features/knowledge/presentation/pages/knowledge_webview_page.dart';
import 'package:hananote/features/measurement/domain/entities/measurement_entry.dart';
import 'package:hananote/features/measurement/presentation/blocs/measurement_bloc.dart';
import 'package:hananote/features/measurement/presentation/pages/measurement_edit_page.dart';
import 'package:hananote/features/measurement/presentation/pages/measurement_page.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/medication/domain/usecases/add_drug.dart';
import 'package:hananote/features/medication/domain/usecases/delete_drug.dart';
import 'package:hananote/features/medication/domain/usecases/get_all_drugs.dart';
import 'package:hananote/features/medication/domain/usecases/update_drug.dart';
import 'package:hananote/features/medication/presentation/bloc/drug_list_cubit.dart';
import 'package:hananote/features/medication/presentation/bloc/inventory_cubit.dart';
import 'package:hananote/features/medication/presentation/bloc/schedule_editor_cubit.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_bloc.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_event.dart';
import 'package:hananote/features/medication/presentation/pages/add_drug_page.dart';
import 'package:hananote/features/medication/presentation/pages/drug_list_page.dart';
import 'package:hananote/features/medication/presentation/pages/inventory_page.dart';
import 'package:hananote/features/medication/presentation/pages/schedule_editor_page.dart';
import 'package:hananote/features/medication/presentation/pages/today_page.dart';
import 'package:hananote/features/notification/presentation/bloc/notification_settings_cubit.dart';
import 'package:hananote/features/notification/presentation/pages/notification_settings_page.dart';
import 'package:hananote/features/photo/domain/entities/photo_entry.dart';
import 'package:hananote/features/photo/presentation/blocs/photo_bloc.dart';
import 'package:hananote/features/photo/presentation/pages/photo_page.dart';
import 'package:hananote/features/photo/presentation/pages/photo_view_page.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/pages/legal_page.dart';
import 'package:hananote/features/settings/presentation/pages/profile_page.dart';
import 'package:hananote/features/settings/presentation/pages/settings_detail_page.dart';
import 'package:hananote/features/simulator/presentation/pages/simulator_page.dart';
import 'package:hananote/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:hananote/features/timeline/presentation/bloc/timeline_event.dart';
import 'package:hananote/features/timeline/presentation/pages/share_poster_page.dart';
import 'package:hananote/features/timeline/presentation/pages/timeline_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

DrugListCubit _createDrugListCubit() {
  return DrugListCubit(
    getIt<GetAllDrugs>(),
    getIt<AddDrug>(),
    getIt<UpdateDrug>(),
    getIt<DeleteDrug>(),
  );
}

/// The main application router configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: requireLocalAuthentication,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapperPage(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider.value(
        value: getIt<SettingsBloc>(),
        child: const OnboardingPage(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    getIt<TodayScheduleBloc>()..add(const LoadTodaySchedule()),
                child: const TodayPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/record',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    getIt<RecordBloc>()..add(const LoadRecordSummary()),
                child: const RecordPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<TimelineBloc>()..add(const LoadTimeline()),
                child: const TimelinePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/data',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    getIt<BloodTestBloc>()..add(const LoadBloodTestDashboard()),
                child: const DataPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => BlocProvider.value(
                value: getIt<SettingsBloc>()
                  ..add(const LoadSettingsDashboard()),
                child: const ProfilePage(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/drugs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => _createDrugListCubit(),
        child: const DrugListPage(),
      ),
    ),
    GoRoute(
      path: '/inventory',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<InventoryCubit>(),
        child: const InventoryPage(),
      ),
    ),
    GoRoute(
      path: '/add_drug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final existingCubit = state.extra;
        final drugListCubit = existingCubit is DrugListCubit
            ? existingCubit
            : _createDrugListCubit();
        return BlocProvider.value(
          value: drugListCubit,
          child: const AddDrugPage(),
        );
      },
    ),
    GoRoute(
      path: '/edit_schedule/:drugId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => ScheduleEditorCubit(getIt<MedicationRepository>())
          ..loadForDrug(state.pathParameters['drugId']!),
        child: const ScheduleEditorPage(),
      ),
    ),
    GoRoute(
      path: '/journal/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JournalEditPage(),
    ),
    GoRoute(
      path: '/share-poster',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider.value(
        value: getIt<SettingsBloc>(),
        child: const SharePosterPage(),
      ),
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthLandingPage(),
    ),
    GoRoute(
      path: '/auth/sign-in',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => AuthBloc(AuthService())..add(const AuthInitRequested()),
        child: const SignInPage(),
      ),
    ),
    GoRoute(
      path: '/auth/sign-up',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => AuthBloc(AuthService())..add(const AuthInitRequested()),
        child: const SignUpPage(),
      ),
    ),
    GoRoute(
      path: '/auth/account',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => AuthBloc(AuthService())..add(const AuthInitRequested()),
        child: const AccountPage(),
      ),
    ),
    GoRoute(
      path: '/record/journal/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JournalEditPage(),
    ),
    GoRoute(
      path: '/measurement',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) =>
            getIt<MeasurementBloc>()..add(const MeasurementEvent.loadHistory()),
        child: const MeasurementPage(),
      ),
    ),
    GoRoute(
      path: '/measurement/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<MeasurementBloc>(),
        child: MeasurementEditPage(
          existingEntry: state.extra as MeasurementEntry?,
        ),
      ),
    ),
    GoRoute(
      path: '/photo',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<PhotoBloc>()..add(const PhotoEvent.loadHistory()),
        child: const PhotoPage(),
      ),
    ),
    GoRoute(
      path: '/photo/view',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        final routeExtra = switch (extra) {
          final PhotoViewRouteExtra value => value,
          final PhotoEntry value => PhotoViewRouteExtra(entry: value),
          _ => throw ArgumentError(
              'Photo view route requires a PhotoEntry or PhotoViewRouteExtra.',
            ),
        };

        return PhotoViewPage(
          entry: routeExtra.entry,
          initialThumbnail: routeExtra.initialThumbnail,
        );
      },
    ),
    GoRoute(
      path: '/data/add_report',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BloodTestEditPage(
        reportId: state.uri.queryParameters['id'],
      ),
    ),
    GoRoute(
      path: '/data/simulator',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SimulatorPage(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider.value(
        value: getIt<SettingsBloc>()..add(const LoadSettingsDashboard()),
        child: const SettingsDetailPage(),
      ),
    ),
    GoRoute(
      path: '/notification_settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<NotificationSettingsCubit>()..loadData(),
          ),
          BlocProvider.value(
            value: getIt<SettingsBloc>()..add(const LoadSettingsDashboard()),
          ),
        ],
        child: const NotificationSettingsPage(),
      ),
    ),
    GoRoute(
      path: '/knowledge',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const KnowledgeWebViewPage(),
    ),
    GoRoute(
      path: '/legal/:type',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => LegalPage(
        type:
            LegalPageType.fromString(state.pathParameters['type'] ?? 'privacy'),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: HanaColors.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: HanaColors.primary),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.error ?? 'Error',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  ),
);
