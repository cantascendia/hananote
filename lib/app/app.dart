import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/app/auth_session_guard.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/router.dart';
import 'package:hananote/app/theme/app_theme.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/privacy/app_blur_overlay.dart';
import 'package:hananote/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';

/// Main application widget.
class HanaNote extends StatelessWidget {
  /// Constructor for [HanaNote].
  const HanaNote({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>(),
      child: BlocProvider(
        create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            Locale? locale;
            if (settingsState is SettingsLoaded) {
              final langCode = settingsState.settings.language;
              if (langCode.isNotEmpty) {
                locale = Locale(langCode);
              }
            }

            final darkModeEnabled = settingsState is SettingsLoaded &&
                settingsState.settings.darkModeEnabled;

            return MaterialApp.router(
              routerConfig: appRouter,
              title: 'HanaNote',
              theme: AppTheme.getTheme(AppThemeType.sakura),
              darkTheme: AppTheme.getTheme(
                AppThemeType.sakura,
                brightness: Brightness.dark,
              ),
              themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                final blurEnabled = settingsState is! SettingsLoaded ||
                    settingsState.settings.blurOverlayEnabled;

                return AppBlurOverlay(
                  enabled: blurEnabled,
                  child: AuthSessionGuard(
                    onLocked: () => appRouter.go('/'),
                    enabled: settingsState is! SettingsLoaded ||
                        settingsState.settings.appLockEnabled,
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
