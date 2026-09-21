import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/core/notifications/notification_service.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/entities/medication_schedule.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/medication/domain/usecases/sync_medication_reminders.dart';
import 'package:hananote/features/settings/domain/entities/app_settings.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(
      MedicationReminderRequest(scheduledAt: DateTime(2026), repeat: null),
    );
  });
  late _MockMedicationRepository repository;
  late _MockNotificationService notificationService;
  late _MockSettingsRepository settingsRepository;
  late SyncMedicationReminders useCase;

  setUp(() {
    repository = _MockMedicationRepository();
    notificationService = _MockNotificationService();
    settingsRepository = _MockSettingsRepository();
    when(() => settingsRepository.getAppSettings()).thenAnswer(
      (_) async => right(const AppSettings(
        appLockEnabled: true,
        privacyModeEnabled: false,
        blurOverlayEnabled: true,
        lastBackupDate: null,
      )),
    );
    useCase = SyncMedicationReminders(
      repository,
      notificationService,
      settingsRepository,
    );
    when(() => notificationService.replaceMedicationReminders(any()))
        .thenAnswer((_) async {});
  });

  Drug buildDrug(String id, {required bool isActive}) => Drug(
        id: id,
        name: 'Drug $id',
        genericName: 'Generic $id',
        category: DrugCategory.estrogen,
        administrationRoute: AdministrationRoute.oral,
        defaultDosageUnit: DosageUnit.mg,
        isActive: isActive,
        createdAt: DateTime(2026),
      );

  MedicationSchedule buildSchedule(String drugId) => MedicationSchedule(
        id: 'schedule-$drugId',
        drugId: drugId,
        dosageAmount: 2,
        dosageUnit: DosageUnit.mg,
        frequency: const MedicationFrequency.daily(timesPerDay: 2),
        administrationRoute: AdministrationRoute.oral,
        startDate: DateTime(2026),
        isActive: true,
        scheduleTimes: const [
          TimeOfDay(hour: 8, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
      );

  group('SyncMedicationReminders', () {
    test('synchronizes 2 active drugs with 2 times each', () async {
      final drugOne = buildDrug('drug-1', isActive: true);
      final drugTwo = buildDrug('drug-2', isActive: true);
      when(() => repository.getAllDrugs())
          .thenAnswer((_) async => right([drugOne, drugTwo]));
      when(() => repository.getScheduleForDrug(drugOne.id))
          .thenAnswer((_) async => right(buildSchedule(drugOne.id)));
      when(() => repository.getScheduleForDrug(drugTwo.id))
          .thenAnswer((_) async => right(buildSchedule(drugTwo.id)));
      final result = await useCase();

      expect(result, right<Failure, int>(4));
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, hasLength(4));
    });

    test('returns right(0) when there are no active drugs', () async {
      when(() => repository.getAllDrugs()).thenAnswer(
        (_) async => right([buildDrug('drug-1', isActive: false)]),
      );

      final result = await useCase();

      expect(result, right<Failure, int>(0));
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, isEmpty);
    });

    test('returns Failure.notification when the repository fails', () async {
      when(() => repository.getAllDrugs()).thenAnswer(
        (_) async => left(const Failure.database(message: 'db unavailable')),
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse(
              (_) => const Failure.unexpected(message: 'unexpected'),
            ),
        const Failure.notification(message: 'db unavailable'),
      );
      verifyNever(() => notificationService.replaceMedicationReminders(any()));
    });

    test('global disable cancels reminders without reading medications',
        () async {
      when(() => settingsRepository.getAppSettings()).thenAnswer(
        (_) async => right(const AppSettings(
          appLockEnabled: true,
          privacyModeEnabled: false,
          blurOverlayEnabled: true,
          lastBackupDate: null,
          notificationsEnabled: false,
        )),
      );
      expect(await useCase(), right<Failure, int>(0));
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, isEmpty);
      verifyNever(() => repository.getAllDrugs());
    });

    test('settings read failure preserves existing reminders', () async {
      when(() => settingsRepository.getAppSettings()).thenAnswer(
        (_) async =>
            left(const Failure.storage(message: 'settings unavailable')),
      );

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      verifyNever(() => notificationService.replaceMedicationReminders(any()));
      verifyNever(() => repository.getAllDrugs());
    });

    test('muted drug remains unscheduled after settings reload', () async {
      final muted = buildDrug('muted', isActive: true);
      final active = buildDrug('active', isActive: true);
      when(() => settingsRepository.getAppSettings()).thenAnswer(
        (_) async => right(const AppSettings(
          appLockEnabled: true,
          privacyModeEnabled: false,
          blurOverlayEnabled: true,
          lastBackupDate: null,
          mutedReminderDrugIds: ['muted'],
        )),
      );
      when(() => repository.getAllDrugs())
          .thenAnswer((_) async => right([muted, active]));
      when(() => repository.getScheduleForDrug(active.id))
          .thenAnswer((_) async => right(buildSchedule(active.id)));
      expect(await useCase(), right<Failure, int>(2));
      verifyNever(() => repository.getScheduleForDrug(muted.id));
      verify(() => repository.getScheduleForDrug(active.id)).called(1);
    });

    test('every-N-days queues only dates aligned to the start date', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day - 3);
      final drug = buildDrug('interval', isActive: true);
      final schedule = buildSchedule(drug.id).copyWith(
        startDate: start,
        frequency: const MedicationFrequency.everyNDays(days: 3),
      );
      when(() => repository.getAllDrugs())
          .thenAnswer((_) async => right([drug]));
      when(() => repository.getScheduleForDrug(drug.id))
          .thenAnswer((_) async => right(schedule));
      final result = await useCase();

      expect(result.isRight(), isTrue);
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, isNotEmpty);
      for (final reminder in plan) {
        final date = reminder.scheduledAt;
        final days = DateTime.utc(date.year, date.month, date.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays;
        expect(days % 3, 0);
        expect(date.isAfter(now), isTrue);
        expect(reminder.repeat, isNull);
      }
    });

    test('weekly repeat starts on the selected weekday', () async {
      final now = DateTime.now();
      final weekday = now.weekday == DateTime.sunday ? 1 : now.weekday + 1;
      final drug = buildDrug('weekly', isActive: true);
      final schedule = buildSchedule(drug.id).copyWith(
        startDate: DateTime(now.year, now.month, now.day - 8),
        frequency: MedicationFrequency.weekly(dayOfWeek: weekday),
      );
      when(() => repository.getAllDrugs())
          .thenAnswer((_) async => right([drug]));
      when(() => repository.getScheduleForDrug(drug.id))
          .thenAnswer((_) async => right(schedule));
      final result = await useCase();

      expect(result, right<Failure, int>(2));
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, hasLength(2));
      for (final reminder in plan) {
        expect(reminder.scheduledAt.weekday, weekday);
        expect(reminder.repeat, DateTimeComponents.dayOfWeekAndTime);
      }
    });

    test('custom interval respects its end date', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day - 4);
      final end = DateTime(now.year, now.month, now.day + 8);
      final drug = buildDrug('custom', isActive: true);
      final schedule = buildSchedule(drug.id).copyWith(
        startDate: start,
        endDate: end,
        intervalDays: 4,
        frequency: const MedicationFrequency.custom(description: 'interval'),
      );
      when(() => repository.getAllDrugs())
          .thenAnswer((_) async => right([drug]));
      when(() => repository.getScheduleForDrug(drug.id))
          .thenAnswer((_) async => right(schedule));
      final result = await useCase();

      expect(result.isRight(), isTrue);
      final plan = verify(
        () => notificationService.replaceMedicationReminders(captureAny()),
      ).captured.single as List<MedicationReminderRequest>;
      expect(plan, isNotEmpty);
      for (final reminder in plan) {
        final date = reminder.scheduledAt;
        final days = DateTime.utc(date.year, date.month, date.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays;
        expect(days % 4, 0);
        expect(date.isAfter(end.add(const Duration(days: 1))), isFalse);
        expect(reminder.repeat, isNull);
      }
    });
  });
}
