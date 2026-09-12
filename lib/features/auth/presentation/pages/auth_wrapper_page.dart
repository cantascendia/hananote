import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_state.dart';
import 'package:hananote/features/auth/presentation/pages/lock_screen_page.dart';
import 'package:hananote/features/auth/presentation/pages/setup_page.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_event.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';

/// Root page that switches between setup, lock, and home flows.
class AuthWrapperPage extends StatelessWidget {
  /// Creates [AuthWrapperPage].
  const AuthWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthUnlocked) {
          final settingsBloc = context.read<SettingsBloc>();
          settingsBloc.add(const LoadSettingsDashboard());

          // After settings load, check onboarding status.
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final settingsState = settingsBloc.state;
            if (settingsState is SettingsLoaded &&
                !settingsState.settings.onboardingComplete) {
              if (context.mounted) context.go('/onboarding');
            } else {
              if (context.mounted) context.go('/today');
            }
          });
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() || AuthUnlocking() => const _LoadingPage(),
            AuthNeedsSetup() || AuthWiped() => const SetupPage(),
            AuthLocked(:final biometricAvailable) =>
              LockScreenPage(biometricAvailable: biometricAvailable),
            AuthUnlocked() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            AuthError() => const _LoadingPage(),
          };
        },
      ),
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
