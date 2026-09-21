import 'package:flutter/material.dart';
import 'package:hananote/app/app.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/core/auth/supabase_client.dart';
import 'package:hananote/core/constants/observability.dart';
import 'package:hananote/core/database/database_factory.dart';
import 'package:hananote/core/error/error_boundary.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:hananote/core/observability/sentry_init.dart';
import 'package:hananote/core/region/region_resolver.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  ErrorBoundary.init(_startApplication);
}

Future<void> _startApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  initDatabaseFactory();
  configureDependencies();

  if (HanaSupabase.isConfigured) {
    final region = await RegionResolver().resolve();
    await HanaSupabase.ensureInitialized(region: region);
  }

  await initSentryIfEnabled(
    dsn: ObservabilityConstants.sentryDsn,
    appRunner: () async {
      try {
        await getIt<NotificationService>().init();
        await getIt<NotificationService>().requestPermissions();
      } catch (_) {
        ErrorBoundary.logAbstractFailure('notification_initialization');
      }

      runApp(const HanaNote());
    },
  );
}
