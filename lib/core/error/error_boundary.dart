import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hananote/core/error/error_fallback_page.dart';

/// Global error boundary that catches unhandled Flutter and platform errors.
class ErrorBoundary {
  ErrorBoundary._();

  static bool _appStarted = false;
  static bool _fallbackShown = false;
  static void Function(Widget app) _appLauncher = runApp;
  static void Function(String message) _debugLogger = debugPrint;

  /// Marks that the main app widget has been handed to Flutter.
  static void markAppStarted() {
    _appStarted = true;
  }

  /// Exposes whether the main app widget has been started for tests.
  @visibleForTesting
  static bool get appStarted => _appStarted;

  /// Resets the internal startup state so tests can run in isolation.
  @visibleForTesting
  static void resetForTest() {
    _appStarted = false;
    _fallbackShown = false;
    _appLauncher = runApp;
    _debugLogger = debugPrint;
  }

  /// Overrides the app launcher used for fallback UI during tests.
  @visibleForTesting
  static void setAppLauncherForTest(void Function(Widget app)? appLauncher) {
    _appLauncher = appLauncher ?? runApp;
  }

  /// Overrides the debug logger used by tests.
  @visibleForTesting
  static void setDebugLoggerForTest(void Function(String message)? logger) {
    _debugLogger = logger ?? debugPrint;
  }

  /// Records an abstract startup failure without including user data.
  static void logAbstractFailure(String operation) {
    assert(operation.isNotEmpty, 'operation must not be empty');
    _log('startup_${operation}_failed');
  }

  /// Call once in `main()` before `runApp()`.
  static Future<void> init(Future<void> Function() appRunner) {
    _appStarted = false;
    _fallbackShown = false;
    final completion = Completer<void>();

    runZonedGuarded<void>(
      () async {
        FlutterError.onError = (_) => _log('flutter_framework_error');
        ErrorWidget.builder = (_) => const MaterialApp(
              home: ErrorFallbackPage(),
            );
        PlatformDispatcher.instance.onError = (_, __) {
          _log('platform_error');
          return true;
        };

        try {
          await appRunner();
          _appStarted = true;
        } catch (_, __) {
          _showFallback();
        } finally {
          if (!completion.isCompleted) completion.complete();
        }
      },
      (_, __) {
        _showFallback();
        if (!completion.isCompleted) completion.complete();
      },
    );
    return completion.future;
  }

  static void _showFallback() {
    _log('startup_error');
    if (_appStarted || _fallbackShown) return;

    _fallbackShown = true;
    _appLauncher(
      const MaterialApp(home: ErrorFallbackPage()),
    );
  }

  static void _log(String operation) {
    if (kDebugMode) _debugLogger('[ErrorBoundary] $operation');
  }
}
