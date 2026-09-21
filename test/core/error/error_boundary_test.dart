import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/error/error_boundary.dart';
import 'package:hananote/core/error/error_fallback_page.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late void Function(FlutterErrorDetails details)? originalFlutterError;
  late ErrorWidgetBuilder originalErrorWidgetBuilder;
  late bool Function(Object, StackTrace)? originalPlatformOnError;

  setUp(() {
    ErrorBoundary.resetForTest();
    originalFlutterError = FlutterError.onError;
    originalErrorWidgetBuilder = ErrorWidget.builder;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    ErrorBoundary.resetForTest();
    FlutterError.onError = originalFlutterError;
    ErrorWidget.builder = originalErrorWidgetBuilder;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
  });

  test('ErrorBoundary.init invokes the provided appRunner', () async {
    var called = false;

    await ErrorBoundary.init(() async {
      called = true;
    });

    expect(called, isTrue);
  });

  test('ErrorBoundary.init installs a platform error handler', () async {
    await ErrorBoundary.init(() async {});

    final onError = PlatformDispatcher.instance.onError;

    expect(onError, isNotNull);
    expect(onError!(StateError('boom'), StackTrace.empty), isTrue);
  });

  test('ErrorBoundary logs abstract platform failures only', () async {
    final logs = <String>[];
    ErrorBoundary.setDebugLoggerForTest(logs.add);
    await ErrorBoundary.init(() async {});

    PlatformDispatcher.instance.onError!(
      StateError('estradiol dose 4mg'),
      StackTrace.empty,
    );

    expect(logs, contains('[ErrorBoundary] platform_error'));
    expect(logs.join(), isNot(contains('estradiol dose 4mg')));
  });

  test('ErrorBoundary.markAppStarted flips the started flag', () {
    expect(ErrorBoundary.appStarted, isFalse);

    ErrorBoundary.markAppStarted();

    expect(ErrorBoundary.appStarted, isTrue);
  });

  testWidgets('ErrorFallbackPage renders localized fallback copy',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ErrorFallbackPage(),
      ),
    );

    final context = tester.element(find.byType(ErrorFallbackPage));
    final l10n = AppLocalizations.of(context)!;

    expect(find.text(l10n.errorFallbackTitle), findsOneWidget);
    expect(find.text(l10n.errorFallbackDescription), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('ErrorWidget.builder returns the fallback page after init',
      (tester) async {
    await ErrorBoundary.init(() async {});

    final widget = ErrorWidget.builder(
      FlutterErrorDetails(exception: StateError('broken subtree')),
    );

    await tester.pumpWidget(widget);

    expect(find.byType(ErrorFallbackPage), findsOneWidget);
  });

  testWidgets('ErrorBoundary.init shows fallback UI when appRunner throws',
      (tester) async {
    Widget? fallbackWidget;
    final fallbackShown = Completer<void>();
    ErrorBoundary.setAppLauncherForTest((app) {
      fallbackWidget = app;
      if (!fallbackShown.isCompleted) {
        fallbackShown.complete();
      }
    });

    await ErrorBoundary.init(() async {
      throw StateError('init failed');
    }).timeout(const Duration(seconds: 5));
    await fallbackShown.future.timeout(const Duration(seconds: 5));

    expect(fallbackWidget, isNotNull);

    await tester.pumpWidget(fallbackWidget!);

    expect(find.byType(ErrorFallbackPage), findsOneWidget);
    expect(ErrorBoundary.appStarted, isFalse);
  });
}
