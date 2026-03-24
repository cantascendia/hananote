import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'di/injection.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/color_tokens.dart';

/// Root application widget.
class HanaApp extends StatefulWidget {
  /// Creates the root application widget.
  const HanaApp({super.key});

  @override
  State<HanaApp> createState() => _HanaAppState();
}

class _HanaAppState extends State<HanaApp> with WidgetsBindingObserver {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused;

    if (_isObscured != shouldObscure) {
      setState(() {
        _isObscured = shouldObscure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = getIt<GoRouter>();

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.app_title,
      theme: AppTheme.light(),
      routerConfig: router,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            child ?? const SizedBox.shrink(),
            if (_isObscured)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: ColoredBox(
                  color: ColorTokens.privacyOverlay.withValues(alpha: 0.86),
                ),
              ),
          ],
        );
      },
    );
  }
}
