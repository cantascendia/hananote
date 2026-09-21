import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/blood_test/domain/entities/blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/entities/enums.dart';
import 'package:hananote/features/blood_test/domain/entities/hormone_reading.dart';
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart';
import 'package:hananote/features/journal/domain/entities/enums.dart';
import 'package:hananote/features/journal/domain/entities/journal_entry.dart';
import 'package:hananote/features/journal/domain/repositories/journal_repository.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/enums.dart';
import 'package:hananote/features/medication/domain/entities/medication_log.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/entities/user_profile.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:hananote/features/timeline/domain/entities/enums.dart';
import 'package:hananote/features/timeline/domain/usecases/get_timeline_events.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository {}

class _MockBloodTestRepository extends Mock implements BloodTestRepository {}

class _MockJournalRepository extends Mock implements JournalRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockMedicationRepository medicationRepository;
  late _MockBloodTestRepository bloodTestRepository;
  late _MockJournalRepository journalRepository;
  late _MockSettingsRepository settingsRepository;
  late GetTimelineEvents useCase;

  final rangeFrom = DateTime(2026, 3);
  final rangeTo = DateTime(2026, 3, 31);

  final drug = Drug(
    id: 'drug-1',
    name: 'Estradiol',
    genericName: 'Estradiol Valerate',
    category: DrugCategory.estrogen,
    administrationRoute: AdministrationRoute.oral,
    defaultDosageUnit: DosageUnit.mg,
    isActive: true,
    createdAt: DateTime(2026),
  );

  final medicationLog = MedicationLog(
    id: 'log-1',
    scheduleId: 'schedule-1',
    drugId: 'drug-1',
    timestamp: DateTime(2026, 3, 18, 8),
    dosageAmount: 2,
    dosageUnit: DosageUnit.mg,
    administrationRoute: AdministrationRoute.oral,
    status: LogStatus.taken,
  );

  final bloodTestReport = BloodTestReport(
    id: 'report-1',
    testDate: DateTime(2026, 3, 20),
    readings: const [
      HormoneReading(
        id: 'reading-1',
        reportId: 'report-1',
        type: HormoneType.estradiol,
        value: 150,
        unit: 'pg/mL',
      ),
      HormoneReading(
        id: 'reading-2',
        reportId: 'report-1',
        type: HormoneType.testosterone,
        value: 42,
        unit: 'ng/dL',
      ),
    ],
    createdAt: DateTime(2026, 3, 20, 9),
  );

  final journalEntry = JournalEntry(
    id: 'entry-1',
    date: DateTime(2026, 3, 10),
    content: '今天感觉平静，也更能和身体相处了。',
    mood: MoodLevel.good,
    createdAt: DateTime(2026, 3, 10, 21),
  );

  setUp(() {
    medicationRepository = _MockMedicationRepository();
    bloodTestRepository = _MockBloodTestRepository();
    journalRepository = _MockJournalRepository();
    settingsRepository = _MockSettingsRepository();
    useCase = GetTimelineEvents(
      medicationRepository,
      bloodTestRepository,
      journalRepository,
      settingsRepository,
    );
  });

  void stubUserProfile(UserProfile profile) {
    when(() => settingsRepository.getUserProfile())
        .thenAnswer((_) async => right(profile));
  }

  void stubEmptyRepositories() {
    when(() => medicationRepository.getAllDrugs())
        .thenAnswer((_) async => right(<Drug>[]));
    when(() => bloodTestRepository.getAllReports())
        .thenAnswer((_) async => right(<BloodTestReport>[]));
    when(
      () => journalRepository.getAllEntries(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => right(<JournalEntry>[]));
  }

  group('GetTimelineEvents', () {
    test('aggregates medication, blood test, and journal events', () async {
      stubUserProfile(
        UserProfile.withCalculatedHrtDayCount(
          displayName: '小花',
          hrtStartDate: DateTime(2026, 1, 15),
          today: rangeTo,
        ),
      );
      when(() => medicationRepository.getAllDrugs())
          .thenAnswer((_) async => right([drug]));
      when(
        () => medicationRepository.getLogsForDrug(
          drug.id,
          from: rangeFrom,
          to: rangeTo,
        ),
      ).thenAnswer((_) async => right([medicationLog]));
      when(() => bloodTestRepository.getAllReports())
          .thenAnswer((_) async => right([bloodTestReport]));
      when(
        () => journalRepository.getAllEntries(
          from: rangeFrom,
          to: rangeTo,
        ),
      ).thenAnswer((_) async => right([journalEntry]));

      final result = await useCase(from: rangeFrom, to: rangeTo);

      expect(result.isRight(), isTrue);
      final events =
          result.getOrElse((_) => throw StateError('expected events'));
      expect(events, hasLength(3));
      expect(events[0].type, TimelineEventType.bloodTest);
      expect(events[1].type, TimelineEventType.medication);
      expect(events[2].type, TimelineEventType.journal);
      expect(events[1].title, 'medication');
      expect(events[1].subtitle, 'taken');
      expect(events[0].title, 'blood_test');
      expect(events[0].subtitle, contains('pg/mL'));
      expect(events[2].subtitle, isNotEmpty);
    });

    test('skips failed data sources and keeps other events', () async {
      stubUserProfile(
        UserProfile.withCalculatedHrtDayCount(
          displayName: '小花',
          hrtStartDate: DateTime(2026, 2),
          today: rangeTo,
        ),
      );
      when(() => medicationRepository.getAllDrugs()).thenAnswer(
        (_) async => left(const Failure.storage(message: 'medication failed')),
      );
      when(() => bloodTestRepository.getAllReports())
          .thenAnswer((_) async => right([bloodTestReport]));
      when(
        () => journalRepository.getAllEntries(
          from: rangeFrom,
          to: rangeTo,
        ),
      ).thenAnswer((_) async => right([journalEntry]));

      final result = await useCase(from: rangeFrom, to: rangeTo);

      expect(result.isRight(), isTrue);
      final events =
          result.getOrElse((_) => throw StateError('expected events'));
      expect(events.map((event) => event.type), [
        TimelineEventType.bloodTest,
        TimelineEventType.journal,
      ]);
    });

    test('calculates milestone events at every 100-day interval', () async {
      stubEmptyRepositories();
      stubUserProfile(
        UserProfile.withCalculatedHrtDayCount(
          displayName: '小花',
          hrtStartDate: DateTime(2025, 8, 13),
          today: rangeTo,
        ),
      );

      final result = await useCase(
        from: DateTime(2025),
        to: rangeTo,
      );

      final events = result.getOrElse(
        (_) => throw StateError('expected milestone events'),
      );
      final milestones = events
          .where((event) => event.type == TimelineEventType.milestone)
          .toList();

      expect(milestones, hasLength(2));
      expect(milestones.first.metadata?['milestoneDays'], 200);
      expect(milestones.last.metadata?['milestoneDays'], 100);
    });

    test('test: unknown HRT start date creates no milestone events', () async {
      stubEmptyRepositories();
      stubUserProfile(
        UserProfile.withCalculatedHrtDayCount(displayName: ''),
      );

      final result = await useCase(from: DateTime(2025), to: rangeTo);
      final events = result.getOrElse(
        (_) => throw StateError('expected timeline events'),
      );

      expect(
        events.where((event) => event.type == TimelineEventType.milestone),
        isEmpty,
      );
    });

    test('returns events sorted by descending date', () async {
      stubUserProfile(
        UserProfile.withCalculatedHrtDayCount(
          displayName: '小花',
          hrtStartDate: DateTime(2026, 2),
          today: rangeTo,
        ),
      );
      when(() => medicationRepository.getAllDrugs())
          .thenAnswer((_) async => right([drug]));
      when(
        () => medicationRepository.getLogsForDrug(
          drug.id,
          from: rangeFrom,
          to: rangeTo,
        ),
      ).thenAnswer((_) async => right([medicationLog]));
      when(() => bloodTestRepository.getAllReports())
          .thenAnswer((_) async => right([bloodTestReport]));
      when(
        () => journalRepository.getAllEntries(
          from: rangeFrom,
          to: rangeTo,
        ),
      ).thenAnswer((_) async => right([journalEntry]));

      final result = await useCase(from: rangeFrom, to: rangeTo);

      final events =
          result.getOrElse((_) => throw StateError('expected events'));
      final sortedDates = events.map((event) => event.date).toList();
      final expectedDates = List<DateTime>.of(sortedDates)
        ..sort((left, right) => right.compareTo(left));
      expect(
        sortedDates,
        orderedEquals(expectedDates),
      );
    });
  });
}
