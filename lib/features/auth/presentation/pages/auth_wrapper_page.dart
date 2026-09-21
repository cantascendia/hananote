import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/core/constants/app_urls.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/update/update_dialog.dart';
import 'package:hananote/core/update/update_service.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/auth_error_message.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:hananote/features/auth/presentation/pages/lock_screen_page.dart';
import 'package:hananote/features/auth/presentation/pages/setup_page.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';

/// Root page that switches between setup, lock, and home flows.
///
/// After auth unlocks the app, this widget waits for [SettingsBloc] to load
/// and then routes to either `/onboarding` (first launch) or `/today`.
class AuthWrapperPage extends StatelessWidget {
  /// Creates [AuthWrapperPage].
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(authErrorMessage(
                  AppLocalizations.of(context)!,
                  state.message,
                ))));
            } else if (state is AuthUnlocked) {
              // Trigger settings load; navigation happens in the listener
              // below once SettingsLoaded arrives.
              context.read<SettingsBloc>().add(const LoadSettingsDashboard());
            }
          },
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (prev, curr) =>
              prev is! SettingsLoaded && curr is SettingsLoaded,
          listener: (context, state) {
            if (state is! SettingsLoaded) return;
            final auth = context.read<AuthCubit>().state;
            if (auth is! AuthUnlocked) return;

            if (!state.settings.hasCompletedOnboarding) {
              context.go('/onboarding');
              return;
            }

            context.go('/today');

            if (kIsWeb) return;
            final autoCheck = state.settings.autoCheckUpdate;
            final skippedVersion = state.settings.skippedVersion;
            if (!autoCheck) return;

            SchedulerBinding.instance.addPostFrameCallback((_) async {
              if (!context.mounted) return;
              final info = await UpdateService.checkForUpdate(
                AppConstants.appVersion,
              );
              if (info != null && context.mounted) {
                if (skippedVersion == info.latestVersion) return;
                await showUpdateDialog(context, info);
              }
            });
          },
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() || AuthUnlocking() => const _LoadingPage(),
            AuthNeedsSetup() || AuthWiped() => const SetupPage(),
            AuthLocked(:final biometricAvailable) =>
              LockScreenPage(biometricAvailable: biometricAvailable),
            AuthUnlocked() => const _UnlockedLoadingPage(),
            AuthError() => const _LoadingPage(),
          };
        },
      ),
    );
  }
}

class _UnlockedLoadingPage extends StatelessWidget {
  const _UnlockedLoadingPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsError) return const _LoadingPage();
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.errorFallbackTitle),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context
                      .read<SettingsBloc>()
                      .add(const LoadSettingsDashboard()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
