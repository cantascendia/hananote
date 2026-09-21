import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockAndroidNotifications extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterLocalNotificationsPlugin plugin;
  late _MockSecureStorage storage;
  late NotificationService service;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    registerFallbackValue(
      tz.TZDateTime.from(DateTime.utc(2026), tz.local),
    );
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('id', 'name'),
        iOS: DarwinNotificationDetails(),
      ),
    );
    registerFallbackValue(
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
  });

  setUp(() {
    plugin = _MockFlutterLocalNotificationsPlugin();
    storage = _MockSecureStorage();
    when(() => storage.read(key: 'app_settings')).thenAnswer((_) async => null);
    service = NotificationService(plugin, settingsStorage: storage);
  });

  test('init initializes the plugin', () async {
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);

    await service.init();

    verify(() => plugin.initialize(any())).called(1);
  });

  test('scheduleMedicationReminder schedules a daily repeating reminder',
      () async {
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});

    await service.scheduleMedicationReminder(
      id: 42,
      drugName: 'Estradiol',
      dosage: 2,
      unit: 'mg',
      hour: 8,
      minute: 30,
    );

    final captured = (verify(
      () => plugin.zonedSchedule(
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
        uiLocalNotificationDateInterpretation: captureAny(
          named: 'uiLocalNotificationDateInterpretation',
        ),
        androidScheduleMode: captureAny(named: 'androidScheduleMode'),
        matchDateTimeComponents: captureAny(
          named: 'matchDateTimeComponents',
        ),
      ),
    )..called(1))
        .captured;
    expect(captured[0], 42);
    expect(captured[1], 'HanaNote');
    expect(captured[2], 'You have a reminder');
    expect(captured[4], isA<NotificationDetails>());
    expect(
      captured[5],
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    expect(captured[6], AndroidScheduleMode.inexactAllowWhileIdle);
    expect(captured[7], DateTimeComponents.time);

    final scheduledDate = captured[3] as tz.TZDateTime;
    final localTime = DateTime.fromMillisecondsSinceEpoch(
        scheduledDate.millisecondsSinceEpoch);
    expect(localTime.hour, 8);
    expect(localTime.minute, 30);
  });

  test('cancelAllReminders calls cancelAll on the plugin', () async {
    when(() => plugin.cancelAll()).thenAnswer((_) async {});

    await service.cancelAllReminders();

    verify(() => plugin.cancelAll()).called(1);
  });

  test('replacement stages every new reminder before removing old ids',
      () async {
    when(() => plugin.pendingNotificationRequests()).thenAnswer(
      (_) async => const [
        PendingNotificationRequest(7, 'HanaNote', 'You have a reminder', null),
      ],
    );
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.cancel(any())).thenAnswer((_) async {});

    await service.replaceMedicationReminders([
      MedicationReminderRequest(
        scheduledAt: DateTime(2026, 9, 23, 8),
        repeat: DateTimeComponents.time,
      ),
      MedicationReminderRequest(
        scheduledAt: DateTime(2026, 9, 23, 20),
        repeat: DateTimeComponents.time,
      ),
    ]);

    verifyInOrder([
      () => plugin.zonedSchedule(
            1000000000,
            any(),
            any(),
            any(),
            any(),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
      () => plugin.zonedSchedule(
            1000000001,
            any(),
            any(),
            any(),
            any(),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
      () => plugin.cancel(7),
    ]);
    verifyNever(() => plugin.cancelAll());
  });

  test('replacement failure cleans only staged ids and preserves old ids',
      () async {
    when(() => plugin.pendingNotificationRequests()).thenAnswer(
      (_) async => const [
        PendingNotificationRequest(7, 'HanaNote', 'You have a reminder', null),
      ],
    );
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((invocation) async {
      if (invocation.positionalArguments.first == 1000000001) {
        throw StateError('platform scheduling failure');
      }
    });
    when(() => plugin.cancel(any())).thenAnswer((_) async {});

    await expectLater(
      service.replaceMedicationReminders([
        MedicationReminderRequest(
          scheduledAt: DateTime(2026, 9, 23, 8),
          repeat: DateTimeComponents.time,
        ),
        MedicationReminderRequest(
          scheduledAt: DateTime(2026, 9, 23, 20),
          repeat: DateTimeComponents.time,
        ),
      ]),
      throwsStateError,
    );

    verify(() => plugin.cancel(1000000000)).called(1);
    verifyNever(() => plugin.cancel(7));
    verifyNever(() => plugin.cancelAll());
  });

  test('replacement attempts every stale cancellation before reporting failure',
      () async {
    when(() => plugin.pendingNotificationRequests()).thenAnswer(
      (_) async => const [
        PendingNotificationRequest(7, 'HanaNote', 'You have a reminder', null),
        PendingNotificationRequest(8, 'HanaNote', 'You have a reminder', null),
      ],
    );
    when(() => plugin.cancel(7)).thenThrow(StateError('cancel failure'));
    when(() => plugin.cancel(8)).thenAnswer((_) async {});

    await expectLater(
      service.replaceMedicationReminders(const []),
      throwsStateError,
    );

    verify(() => plugin.cancel(7)).called(1);
    verify(() => plugin.cancel(8)).called(1);
  });

  test('replacement serializes overlapping scheduler mutations', () async {
    final firstSchedule = Completer<void>();
    var scheduleCalls = 0;
    var pendingReads = 0;
    when(() => plugin.pendingNotificationRequests()).thenAnswer((_) async {
      pendingReads++;
      return const [];
    });
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) {
      scheduleCalls++;
      return scheduleCalls == 1 ? firstSchedule.future : Future.value();
    });

    final first = service.replaceMedicationReminders([
      MedicationReminderRequest(
        scheduledAt: DateTime(2026, 9, 23, 8),
        repeat: DateTimeComponents.time,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);
    final second = service.replaceMedicationReminders([
      MedicationReminderRequest(
        scheduledAt: DateTime(2026, 9, 23, 20),
        repeat: DateTimeComponents.time,
      ),
    ]);

    expect(pendingReads, 1);
    firstSchedule.complete();
    await Future.wait([first, second]);

    expect(pendingReads, 2);
  });

  test('uses exact scheduling only when Android reports permission', () async {
    final android = _MockAndroidNotifications();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    when(() => plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()).thenReturn(android);
    when(() => android.canScheduleExactNotifications())
        .thenAnswer((_) async => true);
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});

    await service.scheduleMedicationReminder(id: 1, hour: 8, minute: 30);

    verify(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).called(1);
  });

  test('uses the saved app language for a generic reminder', () async {
    when(() => storage.read(key: 'app_settings'))
        .thenAnswer((_) async => '{"language":"zh"}');
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});

    await service.scheduleMedicationReminder(id: 2, hour: 9, minute: 0);

    verify(
      () => plugin.zonedSchedule(
        2,
        'HanaNote',
        '你有一条提醒',
        any(),
        any(),
        uiLocalNotificationDateInterpretation:
            any(named: 'uiLocalNotificationDateInterpretation'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).called(1);
  });
}
