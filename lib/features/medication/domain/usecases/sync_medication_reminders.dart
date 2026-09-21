import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// Synchronizes scheduled medication reminders with active schedules.
@injectable
class SyncMedicationReminders {
  /// Creates a [SyncMedicationReminders].
  SyncMedicationReminders(
    this._repository,
    this._notificationService,
    this._settingsRepository,
  );

  static const _queueHorizonDays = 90;

  final MedicationRepository _repository;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;

  /// Plans reminders before replacing existing scheduled notifications.
  Future<Either<Failure, int>> call() async {
    try {
      final settingsResult = await _settingsRepository.getAppSettings();
      if (settingsResult.isLeft()) {
        return left(_notificationFailure(settingsResult));
      }
      final settings =
          settingsResult.getOrElse((_) => throw StateError('settings'));
      if (!settings.notificationsEnabled) {
        await _notificationService.replaceMedicationReminders(const []);
        return right(0);
      }

      final drugsResult = await _repository.getAllDrugs();
      if (drugsResult.isLeft()) return left(_notificationFailure(drugsResult));
      final drugs = drugsResult.getOrElse((_) => []);
      final plan = <_PlannedReminder>[];
      final now = DateTime.now();

      for (final drug in drugs.where(
        (drug) =>
            drug.isActive && !settings.mutedReminderDrugIds.contains(drug.id),
      )) {
        final scheduleResult = await _repository.getScheduleForDrug(drug.id);
        if (scheduleResult.isLeft()) {
          return left(_notificationFailure(scheduleResult));
        }
        final schedule = scheduleResult.getOrElse((_) => null);
        if (schedule == null || !schedule.isActive) continue;
        for (final time in schedule.scheduleTimes) {
          plan.addAll(_planForTime(schedule, time, now));
        }
      }

      await _notificationService.replaceMedicationReminders(
        plan
            .map(
              (reminder) => MedicationReminderRequest(
                scheduledAt: reminder.scheduledAt,
                repeat: reminder.repeat,
              ),
            )
            .toList(growable: false),
      );
      return right(plan.length);
    } catch (error) {
      return left(Failure.notification(message: error.toString()));
    }
  }

  Failure _notificationFailure<T>(Either<Failure, T> result) {
    final failure = result.swap().getOrElse(
          (_) => const Failure.notification(message: 'load failed'),
        );
    return Failure.notification(message: failureMessage(failure));
  }

  List<_PlannedReminder> _planForTime(
    MedicationSchedule schedule,
    TimeOfDay time,
    DateTime now,
  ) {
    final repeats = schedule.endDate == null &&
        (schedule.frequency is DailyMedicationFrequency ||
            schedule.frequency is WeeklyMedicationFrequency);
    if (repeats) {
      final first = _nextOccurrence(schedule, time, now);
      if (first == null) return [];
      return [
        _PlannedReminder(
          first,
          schedule.frequency is WeeklyMedicationFrequency
              ? DateTimeComponents.dayOfWeekAndTime
              : DateTimeComponents.time,
        ),
      ];
    }

    final horizon = DateTime(
      now.year,
      now.month,
      now.day + _queueHorizonDays,
      23,
      59,
    );
    final planned = <_PlannedReminder>[];
    var cursor = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    while (
        !cursor.isAfter(horizon) && !_pastEndDate(cursor, schedule.endDate)) {
      if (cursor.isAfter(now) &&
          !cursor.isBefore(schedule.startDate) &&
          _matchesDate(schedule, cursor)) {
        planned.add(_PlannedReminder(cursor, null));
      }
      cursor = DateTime(
        cursor.year,
        cursor.month,
        cursor.day + 1,
        time.hour,
        time.minute,
      );
    }
    return planned;
  }

  DateTime? _nextOccurrence(
    MedicationSchedule schedule,
    TimeOfDay time,
    DateTime now,
  ) {
    final firstDay = schedule.startDate.isAfter(now) ? schedule.startDate : now;
    var cursor = DateTime(
      firstDay.year,
      firstDay.month,
      firstDay.day,
      time.hour,
      time.minute,
    );
    for (var offset = 0; offset < 8; offset++) {
      if (cursor.isAfter(now) &&
          !cursor.isBefore(schedule.startDate) &&
          _matchesDate(schedule, cursor)) {
        return cursor;
      }
      cursor = DateTime(
        cursor.year,
        cursor.month,
        cursor.day + 1,
        time.hour,
        time.minute,
      );
    }
    return null;
  }

  bool _matchesDate(MedicationSchedule schedule, DateTime date) {
    return switch (schedule.frequency) {
      DailyMedicationFrequency() => true,
      WeeklyMedicationFrequency(:final dayOfWeek) => date.weekday == dayOfWeek,
      EveryNDaysMedicationFrequency(:final days) =>
        _calendarDays(schedule.startDate, date) % days == 0,
      CustomMedicationFrequency() => schedule.intervalDays != null &&
          schedule.intervalDays! > 0 &&
          _calendarDays(schedule.startDate, date) % schedule.intervalDays! == 0,
    };
  }

  int _calendarDays(DateTime start, DateTime end) => DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

  bool _pastEndDate(DateTime candidate, DateTime? endDate) =>
      endDate != null &&
      DateTime(candidate.year, candidate.month, candidate.day).isAfter(
        DateTime(endDate.year, endDate.month, endDate.day),
      );
}

class _PlannedReminder {
  const _PlannedReminder(this.scheduledAt, this.repeat);

  final DateTime scheduledAt;
  final DateTimeComponents? repeat;
}
