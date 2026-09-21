import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wrapper around flutter_local_notifications used by features.
@lazySingleton
class NotificationService {
  /// Creates a [NotificationService].
  NotificationService(this._plugin, {FlutterSecureStorage? settingsStorage})
      : _settingsStorage = settingsStorage ?? const FlutterSecureStorage();

  final FlutterLocalNotificationsPlugin _plugin;
  final FlutterSecureStorage _settingsStorage;
  static const _timezoneChannel = MethodChannel('com.hananote.app/timezone');
  Future<void>? _timeZoneInitialization;
  Future<void> _replacementQueue = Future.value();

  static const AndroidNotificationChannel _medicationChannel =
      AndroidNotificationChannel(
    'medication_reminders',
    '服药提醒',
    description: '每日服药提醒通知',
    importance: Importance.high,
  );

  /// Initializes platform notification settings.
  Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);

    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(
      _medicationChannel,
    );
  }

  /// Requests notification permissions from the current platform.
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            true;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(
                  alert: true,
                  badge: true,
                  sound: true,
                ) ??
            true;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  /// Schedules a daily repeating medication reminder.
  ///
  /// Defaults to generic text. Explicit text must not disclose health data.
  /// Medication detail arguments remain optional for source compatibility.
  Future<void> scheduleMedicationReminder({
    required int id,
    required int hour,
    required int minute,
    String? drugName,
    double? dosage,
    String? unit,
    DateTime? scheduledAt,
    DateTimeComponents? matchDateTimeComponents = DateTimeComponents.time,
    String? title,
    String? body,
  }) async {
    final l10n = await _reminderLocalizations();
    final resolvedTitle = title ?? l10n.reminderNotifTitle;
    final resolvedBody = body ?? l10n.reminderNotifBody;

    await (_timeZoneInitialization ??= _configureLocalTimeZone());
    final now = DateTime.now();
    var nextLocalTime = scheduledAt ??
        DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
    if (scheduledAt == null && !nextLocalTime.isAfter(now)) {
      nextLocalTime = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    final scheduledDate = tz.TZDateTime.from(nextLocalTime, tz.local);

    var scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      bool? exactAvailable;
      try {
        exactAvailable = await android?.canScheduleExactNotifications();
      } on PlatformException {
        // Older Android versions or plugin implementations can omit the query.
      }
      if (exactAvailable ?? false) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    await _plugin.zonedSchedule(
      id,
      resolvedTitle,
      resolvedBody,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _medicationChannel.id,
          _medicationChannel.name,
          channelDescription: _medicationChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  /// Cancels a scheduled reminder by id.
  Future<void> cancelReminder(int id) => _plugin.cancel(id);

  /// Cancels all reminders.
  Future<void> cancelAllReminders() => _plugin.cancelAll();

  /// Lists all pending reminders.
  Future<List<PendingNotificationRequest>> getPendingReminders() =>
      _plugin.pendingNotificationRequests();

  /// Replaces medication reminders without removing the prior set until every
  /// replacement has been accepted by the platform.
  ///
  /// HanaNote currently creates scheduled notifications only for medication
  /// reminders. New ids are staged outside the legacy sequential-id range so a
  /// failed replacement leaves the prior schedule intact. Successfully staged
  /// ids become authoritative only after the older pending ids are cancelled.
  Future<void> replaceMedicationReminders(
    List<MedicationReminderRequest> reminders,
  ) =>
      _serializeReplacement(() => _replaceMedicationReminders(reminders));

  Future<void> _replaceMedicationReminders(
    List<MedicationReminderRequest> reminders,
  ) async {
    final existing = await getPendingReminders();
    final existingIds = existing.map((request) => request.id).toSet();
    final replacementIds = _stagingIds(existingIds, reminders.length);
    final stagedIds = <int>[];

    try {
      for (var index = 0; index < reminders.length; index++) {
        final reminder = reminders[index];
        final id = replacementIds[index];
        await scheduleMedicationReminder(
          id: id,
          hour: reminder.scheduledAt.hour,
          minute: reminder.scheduledAt.minute,
          scheduledAt: reminder.scheduledAt,
          matchDateTimeComponents: reminder.repeat,
        );
        stagedIds.add(id);
      }
    } catch (_) {
      for (final id in stagedIds) {
        try {
          await cancelReminder(id);
        } catch (_) {
          // Preserve the scheduling error; a later sync removes this staging id.
        }
      }
      rethrow;
    }

    Object? cancellationError;
    StackTrace? cancellationStackTrace;
    for (final id in existingIds) {
      try {
        await cancelReminder(id);
      } catch (error, stackTrace) {
        cancellationError ??= error;
        cancellationStackTrace ??= stackTrace;
      }
    }
    if (cancellationError != null) {
      Error.throwWithStackTrace(cancellationError, cancellationStackTrace!);
    }
  }

  Future<T> _serializeReplacement<T>(Future<T> Function() action) {
    final completion = Completer<T>();
    _replacementQueue = _replacementQueue.catchError((_) {}).then((_) async {
      try {
        completion.complete(await action());
      } catch (error, stackTrace) {
        completion.completeError(error, stackTrace);
      }
    });
    return completion.future;
  }

  List<int> _stagingIds(Set<int> existingIds, int count) {
    const firstStagingId = 1000000000;
    final ids = <int>[];
    var candidate = firstStagingId;
    while (ids.length < count) {
      if (!existingIds.contains(candidate)) {
        ids.add(candidate);
      }
      candidate++;
    }
    return ids;
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final zoneId =
          await _timezoneChannel.invokeMethod<String>('getTimeZoneId');
      if (zoneId != null && zoneId.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(zoneId));
      }
    } on MissingPluginException {
      // Non-Android tests and older hosts have no native timezone channel.
    } on PlatformException {
      // The absolute first trigger remains correct if lookup is unavailable.
    } on tz.LocationNotFoundException {
      // Device timezone data can be newer than the bundled timezone database.
    }
  }

  Future<AppLocalizations> _reminderLocalizations() async {
    var language = PlatformDispatcher.instance.locale.languageCode;
    try {
      final raw = await _settingsStorage.read(key: 'app_settings');
      if (raw != null) {
        final settings = jsonDecode(raw) as Map<String, dynamic>;
        final selected = settings['language'];
        if (selected is String && selected.isNotEmpty) {
          language = selected;
        }
      }
    } catch (_) {
      // Reminders remain available if settings storage is temporarily locked.
    }
    final code = language.split(RegExp('[-_]')).first.toLowerCase();
    final supported = const {'en', 'ja', 'zh'}.contains(code) ? code : 'en';
    return lookupAppLocalizations(Locale(supported));
  }
}

/// A privacy-safe medication reminder to stage with the platform scheduler.
class MedicationReminderRequest {
  /// Creates a request for one local device-time medication reminder.
  const MedicationReminderRequest({
    required this.scheduledAt,
    required this.repeat,
  });

  /// The intended local wall-clock occurrence.
  final DateTime scheduledAt;

  /// Repetition semantics supported by the notification platform.
  final DateTimeComponents? repeat;
}
