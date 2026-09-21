import 'package:fpdart/fpdart.dart';
import 'package:hananote/core/error/failures.dart';
import 'package:hananote/features/blood_test/domain/entities/blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/entities/enums.dart';
import 'package:hananote/features/blood_test/domain/repositories/blood_test_repository.dart';
import 'package:hananote/features/journal/domain/entities/enums.dart';
import 'package:hananote/features/journal/domain/entities/journal_entry.dart';
import 'package:hananote/features/journal/domain/repositories/journal_repository.dart';
import 'package:hananote/features/medication/domain/entities/drug.dart';
import 'package:hananote/features/medication/domain/entities/medication_log.dart';
import 'package:hananote/features/medication/domain/repositories/medication_repository.dart';
import 'package:hananote/features/settings/domain/repositories/settings_repository.dart';
import 'package:hananote/features/timeline/domain/entities/enums.dart';
import 'package:hananote/features/timeline/domain/entities/timeline_event.dart';
import 'package:injectable/injectable.dart';

/// Aggregates read-only events across features for the timeline tab.
@injectable
class GetTimelineEvents {
  /// Creates a [GetTimelineEvents].
  GetTimelineEvents(
    this._medicationRepository,
    this._bloodTestRepository,
    this._journalRepository,
    this._settingsRepository,
  );

  final MedicationRepository _medicationRepository;
  final BloodTestRepository _bloodTestRepository;
  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  /// Executes the use case.
  Future<Either<Failure, List<TimelineEvent>>> call({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final eventGroups = await Future.wait([
        _loadMedicationEvents(from: from, to: to),
        _loadBloodTestEvents(from: from, to: to),
        _loadJournalEvents(from: from, to: to),
        _loadMilestoneEvents(from: from, to: to),
      ]);

      final events = eventGroups.expand((group) => group).toList()
        ..sort((left, right) => right.date.compareTo(left.date));

      return right(events);
    } catch (error) {
      return left(Failure.unexpected(message: error.toString()));
    }
  }

  Future<List<TimelineEvent>> _loadMedicationEvents({
    DateTime? from,
    DateTime? to,
  }) async {
    final drugsResult = await _medicationRepository.getAllDrugs();

    return drugsResult.fold<Future<List<TimelineEvent>>>(
      (_) async => <TimelineEvent>[],
      (drugs) async {
        final logGroups = await Future.wait(
          drugs.map((drug) async {
            final logsResult = await _medicationRepository.getLogsForDrug(
              drug.id,
              from: from,
              to: to,
            );

            return logsResult.fold(
              (_) => <TimelineEvent>[],
              (logs) => logs
                  .where(
                    (log) => _isWithinRange(log.timestamp, from: from, to: to),
                  )
                  .map((log) => _mapMedicationLog(drug, log))
                  .toList(),
            );
          }),
        );

        return logGroups.expand((group) => group).toList();
      },
    );
  }

  Future<List<TimelineEvent>> _loadBloodTestEvents({
    DateTime? from,
    DateTime? to,
  }) async {
    final reportsResult = await _bloodTestRepository.getAllReports();

    return reportsResult.fold(
      (_) => <TimelineEvent>[],
      (reports) => reports
          .where(
            (report) => _isWithinRange(report.testDate, from: from, to: to),
          )
          .map(_mapBloodTestReport)
          .toList(),
    );
  }

  Future<List<TimelineEvent>> _loadJournalEvents({
    DateTime? from,
    DateTime? to,
  }) async {
    final entriesResult = await _journalRepository.getAllEntries(
      from: from,
      to: to,
    );

    return entriesResult.fold(
      (_) => <TimelineEvent>[],
      (entries) => entries.map(_mapJournalEntry).toList(),
    );
  }

  Future<List<TimelineEvent>> _loadMilestoneEvents({
    DateTime? from,
    DateTime? to,
  }) async {
    final profileResult = await _settingsRepository.getUserProfile();

    return profileResult.fold(
      (_) => <TimelineEvent>[],
      (profile) {
        final hrtStartDate = profile.hrtStartDate;
        if (hrtStartDate == null) return <TimelineEvent>[];
        final startDate = _normalizeDate(hrtStartDate);
        final endDate = _normalizeDate(to ?? DateTime.now());
        if (endDate.isBefore(startDate)) {
          return <TimelineEvent>[];
        }

        final totalDays = endDate.difference(startDate).inDays;
        final milestoneEvents = <TimelineEvent>[];

        for (var dayCount = 100; dayCount <= totalDays; dayCount += 100) {
          final milestoneDate = startDate.add(Duration(days: dayCount));
          if (_isWithinRange(milestoneDate, from: from, to: to)) {
            milestoneEvents.add(
              TimelineEvent(
                id: 'milestone-$dayCount',
                date: milestoneDate,
                type: TimelineEventType.milestone,
                title: 'milestone',
                metadata: <String, dynamic>{
                  'milestoneDays': dayCount,
                  'startDate': startDate.toIso8601String(),
                },
              ),
            );
          }
        }

        return milestoneEvents;
      },
    );
  }

  TimelineEvent _mapMedicationLog(Drug drug, MedicationLog log) {
    return TimelineEvent(
      id: 'medication-${log.id}',
      date: log.timestamp,
      type: TimelineEventType.medication,
      title: 'medication',
      subtitle: log.status.name,
      metadata: <String, dynamic>{
        'drugId': drug.id,
        'drugName': drug.name,
        'status': log.status.name,
        'route': log.administrationRoute.name,
        'dosageAmount': log.dosageAmount,
        'dosageUnit': log.dosageUnit.name,
      },
    );
  }

  TimelineEvent _mapBloodTestReport(BloodTestReport report) {
    final readingSummary = report.readings.take(3).map((reading) {
      return '${reading.type.name}: ${_formatReadingValue(reading.value)}'
          ' ${reading.unit}';
    }).join(' · ');
    final normalCount = report.readings
        .where(
          (reading) =>
              reading.type.statusFor(reading.value) == HormoneStatus.normal,
        )
        .length;
    final targetRate =
        report.readings.isEmpty ? 0.0 : normalCount / report.readings.length;

    return TimelineEvent(
      id: 'blood-test-${report.id}',
      date: report.testDate,
      type: TimelineEventType.bloodTest,
      title: 'blood_test',
      subtitle: readingSummary.isEmpty ? '' : readingSummary,
      metadata: <String, dynamic>{
        'reportId': report.id,
        'labName': report.labName,
        'readingCount': report.readings.length,
        'normalCount': normalCount,
        'targetRate': targetRate,
      },
    );
  }

  TimelineEvent _mapJournalEntry(JournalEntry entry) {
    return TimelineEvent(
      id: 'journal-${entry.id}',
      date: entry.date,
      type: TimelineEventType.journal,
      title: _truncate(entry.content, 50),
      subtitle: entry.mood.emoji,
      metadata: <String, dynamic>{
        'entryId': entry.id,
        'mood': entry.mood.name,
        'contentLength': entry.content.length,
      },
    );
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength)}…';
  }

  String _formatReadingValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  bool _isWithinRange(DateTime date, {DateTime? from, DateTime? to}) {
    final normalizedDate = _normalizeDate(date);
    final normalizedFrom = from == null ? null : _normalizeDate(from);
    final normalizedTo = to == null ? null : _normalizeDate(to);

    if (normalizedFrom != null && normalizedDate.isBefore(normalizedFrom)) {
      return false;
    }

    if (normalizedTo != null && normalizedDate.isAfter(normalizedTo)) {
      return false;
    }

    return true;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
