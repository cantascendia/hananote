import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';

/// Available date ranges for the timeline filter.
enum TimelineRange {
  /// Events from the last month.
  oneMonth,

  /// Events from the last three months.
  threeMonths,

  /// Events from the last six months.
  sixMonths,

  /// Events from the last year.
  oneYear,

  /// No date limit.
  all,
}

/// Presentation helpers for [TimelineRange].
extension TimelineRangeX on TimelineRange {
  /// Date range represented by the selected filter.
  ({DateTime from, DateTime to})? get dateRange {
    if (this == TimelineRange.all) {
      return null;
    }

    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    final from = switch (this) {
      TimelineRange.oneMonth => to.subtract(const Duration(days: 30)),
      TimelineRange.threeMonths => to.subtract(const Duration(days: 90)),
      TimelineRange.sixMonths => to.subtract(const Duration(days: 180)),
      TimelineRange.oneYear => to.subtract(const Duration(days: 365)),
      TimelineRange.all => to,
    };

    return (from: from, to: to);
  }
}

/// Events handled by the timeline bloc.
@freezed
sealed class TimelineBlocEvent with _$TimelineBlocEvent {
  /// Loads the selected timeline range.
  const factory TimelineBlocEvent.loadTimeline() = LoadTimeline;

  /// Changes the selected range and reloads the timeline.
  const factory TimelineBlocEvent.selectRange(TimelineRange range) =
      SelectTimelineRange;
}
