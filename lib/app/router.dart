import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/medication/presentation/pages/medication_list_page.dart';
import '../l10n/generated/app_localizations.dart';

/// Builds the application router.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const _WelcomePage()),
      GoRoute(
        path: '/medication',
        builder: (context, state) => const MedicationListPage(),
      ),
    ],
  );
}

/// Provides access to localized strings from a [BuildContext].
extension AppLocalizationsX on BuildContext {
  /// Returns the generated localization instance.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: theme.colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.app_title,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
