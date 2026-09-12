// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/presentation/main_shell.dart' show kNavBarContentHeight;
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/features/timeline/domain/entities/enums.dart';
import 'package:hananote/features/timeline/domain/entities/timeline_event.dart';
import 'package:hananote/features/timeline/presentation/bloc/timeline_bloc.dart';
import 'package:hananote/features/timeline/presentation/bloc/timeline_event.dart';
import 'package:hananote/features/timeline/presentation/bloc/timeline_state.dart';
import 'package:intl/intl.dart';

/// Timeline page showing aggregated cross-feature events.
class TimelinePage extends StatelessWidget {
  /// Creates a [TimelinePage].
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Removed showComingSoon as buttons now use real navigation

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor:
                  HanaColors.backgroundOf(context).withAlpha((255 * 0.8).round()),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.settings, color: HanaColors.primaryOf(context)),
                onPressed: () => context.push('/settings'),
              ),
              title: Text(
                l10n.myGrowthTrajectory,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: HanaColors.primaryOf(context),
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: HanaColors.primaryOf(context),
                  ),
                  onPressed: () => showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom + kNavBarContentHeight + 16,
          right: 8,
        ),
        child: FloatingActionButton(
          onPressed: () => _showCreateSheet(context, l10n),
          backgroundColor: Colors.transparent,
          elevation: 8,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [HanaColors.primaryOf(context), HanaColors.secondaryOf(context)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      body: BlocBuilder<TimelineBloc, TimelineState>(
        builder: (context, state) {
          return switch (state) {
            TimelineInitial() || TimelineLoading() => Center(
                child: CircularProgressIndicator(color: HanaColors.primaryOf(context)),
              ),
            TimelineError(:final message) => Center(child: Text(message)),
            TimelineLoaded(:final events, :final selectedRange) => _TimelineLoadedView(
                events: events,
                selectedRange: selectedRange,
                emptyLabel: l10n.noTimelineEvents,
              ),
          };
        },
      ),
    );
  }

  Future<void> _showCreateSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: HanaColors.surfaceContainerLowestOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: HanaColors.outlineVariantOf(context).withAlpha(128),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.medication_outlined,
                    color: HanaColors.primaryOf(context),
                  ),
                  title: Text(
                    l10n.logMedication,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/today');
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.edit_note, color: HanaColors.primaryOf(context)),
                  title: Text(
                    l10n.writeJournal,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/record/journal/new');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.science_outlined,
                    color: HanaColors.primaryOf(context),
                  ),
                  title: Text(
                    l10n.addBloodTest,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/data/add_report');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimelineLoadedView extends StatelessWidget {
  const _TimelineLoadedView({
    required this.events,
    required this.selectedRange,
    required this.emptyLabel,
  });

  final List<TimelineEvent> events;
  final TimelineRange selectedRange;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: TextStyle(color: HanaColors.onSurfaceVariantOf(context).withAlpha(153)),
        ),
      );
    }

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return Stack(
      children: [
        // Central Gradient Line Fixed
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HanaColors.primaryContainerOf(context),
                    HanaColors.secondaryContainerOf(context),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        // Content list
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: topPadding, bottom: 24),
              sliver: SliverToBoxAdapter(
                child: _FilterPills(
                  selectedRange: selectedRange,
                  onRangeSelected: (range) {
                    context.read<TimelineBloc>().add(TimelineBlocEvent.selectRange(range));
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  // Right card at even index (0, 2), Left card at odd index (1, 3)
                  // Wait, index 0 -> left column card is false (right card style).
                  // Because in HTML Card 1 was Right aligned.
                  final isCardRight = index.isEven;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _TimelineEventRow(
                      event: event,
                      isCardRight: isCardRight,
                    ),
                  );
                },
                childCount: events.length,
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 24),
              sliver: SliverToBoxAdapter(
                child: _TimelineStartPoint(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final TimelineRange selectedRange;
  final ValueChanged<TimelineRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const filters = TimelineRange.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.map((range) {
          final isSelected = range == selectedRange;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onRangeSelected(range),
              behavior: HitTestBehavior.opaque,
              child: Chip(
                label: Text(
                  range.localizedName(l10n),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected
                        ? HanaColors.onPrimaryContainerOf(context)
                        : HanaColors.onSurfaceVariantOf(context),
                  ),
                ),
                backgroundColor: isSelected
                    ? HanaColors.primaryContainerOf(context)
                    : HanaColors.surfaceContainerHighOf(context),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.event,
    required this.isCardRight,
  });

  final TimelineEvent event;
  final bool isCardRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Column
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 32),
            child: isCardRight
                ? Align(
                    alignment: Alignment.centerRight,
                    child: _DateText(date: event.date),
                  )
                : _EventCard(event: event, isAlignedRight: false),
          ),
        ),
        // Center Dot
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: event.type.borderColor,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: event.type.borderColor.withAlpha(51), // 20%
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Right Column
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 24),
            child: isCardRight
                ? _EventCard(event: event, isAlignedRight: true)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _DateText(date: event.date),
                  ),
          ),
        ),
      ],
    );
  }
}

class _DateText extends StatelessWidget {
  const _DateText({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Text(
        DateFormat('yyyy.MM.dd').format(date),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Be Vietnam Pro',
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.isAlignedRight,
  });

  final TimelineEvent event;
  final bool isAlignedRight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: HanaColors.surfaceContainerLowestOf(context),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          builder: (sheetContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: HanaColors.outlineVariantOf(context).withAlpha(128),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: event.type.borderColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            event.type.icon,
                            color: event.type.iconColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          event.type.localizedName(l10n),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HanaColors.onSurfaceOf(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: HanaColors.onSurfaceOf(context),
                      ),
                    ),
                    if (event.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: HanaColors.onSurfaceVariantOf(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      DateFormat.yMMMd(localeName).format(event.date),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: HanaColors.onSurfaceVariantOf(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(l10n.closeAction),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowestOf(context),
            borderRadius: BorderRadius.circular(12),
            border: isAlignedRight
                ? Border(
                    left: BorderSide(color: event.type.borderColor, width: 4),
                  )
                : Border(
                    right: BorderSide(color: event.type.borderColor, width: 4),
                  ),
            boxShadow: [
              BoxShadow(
                color: HanaColors.primaryOf(context).withAlpha(10), // 4%
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isAlignedRight
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isAlignedRight
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: isAlignedRight
                    ? [
                        Icon(
                          Icons.stars,
                          size: 14,
                          color: event.type.borderColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.type.localizedName(l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: event.type.borderColor.withAlpha(153), // 60%
                          ),
                        ),
                      ]
                    : [
                        Text(
                          event.type.localizedName(l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: event.type.borderColor.withAlpha(153), // 60%
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.stars,
                          size: 14,
                          color: event.type.borderColor,
                        ),
                      ],
              ),
              const SizedBox(height: 4),
              Text(
                event.title,
                textAlign: isAlignedRight ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: HanaColors.onSurfaceOf(context),
                ),
              ),
              if (event.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  event.subtitle!,
                  textAlign: isAlignedRight ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    color: HanaColors.onSurfaceVariantOf(context).withAlpha(204), // 80%
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStartPoint extends StatelessWidget {
  const _TimelineStartPoint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerHighOf(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.psychology, color: HanaColors.primaryOf(context)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.journeyStart,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: HanaColors.onSurfaceVariantOf(context),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: HanaColors.primaryOf(context),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
