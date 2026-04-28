import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A callback that starts the Flutter application (typically calls runApp).
typedef AppRunner = Future<void> Function();

/// Initialises Sentry if the user has opted in AND a non-empty DSN is
/// provided.  Otherwise the appRunner is invoked directly so the app
/// behaves identically with or without crash reporting.
///
/// Privacy guarantees:
/// - Opt-in only: crashReportingEnabled defaults to false.
/// - Empty DSN disables Sentry even if the user toggled the setting on.
/// - No performance traces: tracesSampleRate is 0.0.
/// - beforeSend scrubs any patterns that could identify the user.
Future<void> initSentryIfEnabled({
  required String dsn,
  required AppRunner appRunner,
}) async {
  final enabled = await _isCrashReportingEnabled();

  if (enabled && dsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = dsn
          ..tracesSampleRate = 0.0
          ..attachStacktrace = true
          ..enableUserInteractionBreadcrumbs = false
          ..enableAutoNativeBreadcrumbs = false
          ..beforeSend = _scrubPii;
      },
      appRunner: appRunner,
    );
  } else {
    await appRunner();
  }
}

/// Reads crashReportingEnabled from secure storage without
/// going through the DI graph (called before configureDependencies).
Future<bool> _isCrashReportingEnabled() async {
  try {
    const storage = FlutterSecureStorage();
    final raw = await storage.read(key: 'app_settings');
    if (raw == null) return false;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final settings = AppSettings.fromJson(json);
    return settings.crashReportingEnabled;
  } catch (e) {
    // If we can't read settings, default to off — privacy-first.
    debugPrint('[sentry_init] Could not read settings: $e');
    return false;
  }
}

/// Removes patterns that could identify an individual user from a Sentry
/// event before it is transmitted.
SentryEvent? _scrubPii(SentryEvent event, Hint hint) {
  // Strip user object entirely (we never set it, but be defensive).
  final scrubbed = event.copyWith(user: null);

  // Walk through breadcrumb messages and exception values to remove PII.
  final cleanBreadcrumbs = scrubbed.breadcrumbs?.map((b) {
    final msg = b.message;
    if (msg == null) return b;
    return b.copyWith(message: _removePiiPatterns(msg));
  }).toList();

  final cleanExceptions = scrubbed.exceptions?.map((ex) {
    final value = ex.value;
    if (value == null) return ex;
    return ex.copyWith(value: _removePiiPatterns(value));
  }).toList();

  return scrubbed.copyWith(
    breadcrumbs: cleanBreadcrumbs,
    exceptions: cleanExceptions,
  );
}

// Patterns to redact from crash payloads.
final _emailPattern = RegExp(
  r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
);

// Typical Android/iOS sandboxed file paths containing package names or UUIDs.
final _filePathPattern = RegExp(
  r'(/data/user/\S+|/var/mobile/\S+|/Users/\S+)',
);

String _removePiiPatterns(String input) => input
    .replaceAll(_emailPattern, '[email]')
    .replaceAll(_filePathPattern, '[path]');
