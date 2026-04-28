import 'package:flutter/material.dart';
import 'package:hananote/app/app.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/core/constants/observability.dart';
import 'package:hananote/core/database/database_factory.dart';
import 'package:hananote/core/error/error_boundary.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:hananote/core/observability/sentry_init.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  initDatabaseFactory();
  configureDependencies();

  await initSentryIfEnabled(
    dsn: ObservabilityConstants.sentryDsn,
    appRunner: () async {
      await ErrorBoundary.init(() async {
        try {
          await getIt<NotificationService>().init();
          await getIt<NotificationService>().requestPermissions();
        } catch (e) {
          debugPrint('[main] Notification init error (non-fatal): $e');
        }

        runApp(const HanaNote());
      });
    },
  );
}
