// HanaNote v2 — Today page (HoYo redesign).
// Greeting + plum hero countdown + 3-stat triplet + 已完成 med-rows
// + 待服药 med-rows + Daily 花笺 signature card.
// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/data/flower_almanac.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/core/widgets/hoyo/conic_avatar_ring.dart';
import 'package:hananote/core/widgets/hoyo/hana_daily_card.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_med_row.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_section_title.dart';
import 'package:hananote/core/widgets/petal_celebration.dart';
import 'package:hananote/features/medication/domain/usecases/get_today_schedule.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_bloc.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_event.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_state.dart';
import 'package:hananote/features/medication/presentation/widgets/countdown_card.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:intl/intl.dart';

/// The main dashboard page for the current day's health tracking.
class TodayPage extends StatelessWidget {
  /// Creates a [TodayPage].
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = context.watch<SettingsBloc>().state;
    final displayName = settingsState is SettingsLoaded &&
            settingsState.profile.displayName.isNotEmpty
        ? settingsState.profile.displayName
        : l10n.defaultUserName;
    final hrtDays =
        settingsState is SettingsLoaded ? settingsState.profile.hrtDayCount : 0;
    final greeting = _greetingForHour(DateTime.now().hour, l10n);
    final signatureChar = _signatureCharFromName(displayName);

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      appBar: HoyoAppBar(
        title: l10n.appTitle,
        subtitle: DateFormat.MMMd(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(DateTime.now()),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              size: 18,
              color: HanaColors.primaryOf(context),
            ),
            onPressed: () => context.go('/timeline'),
          ),
        ],
      ),
      body: BlocListener<TodayScheduleBloc, TodayScheduleState>(
        listenWhen: (prev, curr) {
          final prevCount =
              prev.mapOrNull(loaded: (s) => s.completedCount) ?? 0;
          final currCount =
              curr.mapOrNull(loaded: (s) => s.completedCount) ?? 0;
          return currCount > prevCount;
        },
        listener: (context, state) {
          PetalCelebration.show(context);
        },
        child: BlocBuilder<TodayScheduleBloc, TodayScheduleState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Greeting row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HoyoEyebrow('Welcome back'),
                              const SizedBox(height: 8),
                              Text(
                                '$greeting，$displayName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HanaTypography.displaySm.copyWith(
                                  color: HanaColors.primaryOf(context),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.64,
                                ),
                              ),
                              if (settingsState is SettingsLoaded &&
                                  settingsState.profile.hrtStartDate !=
                                      null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  l10n.hrtDay(hrtDays),
                                  style: HanaTypography.labelMd.copyWith(
                                    color:
                                        HanaColors.onSurfaceVariantOf(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: ConicAvatarRing(
                            label: signatureChar,
                            size: 56,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ..._buildStateContent(
                  context,
                  state,
                  l10n,
                  hrtDays: hrtDays,
                  hasHrtStartDate: settingsState is SettingsLoaded &&
                      settingsState.profile.hrtStartDate != null,
                  signatureChar: signatureChar,
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildStateContent(
    BuildContext context,
    TodayScheduleState state,
    AppLocalizations l10n, {
    required int hrtDays,
    required bool hasHrtStartDate,
    required String signatureChar,
  }) {
    return state.when(
      initial: () => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      loading: () => const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (message) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  style: TextStyle(color: HanaColors.errorOf(context)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<TodayScheduleBloc>()
                      .add(const LoadTodaySchedule()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ],
      loaded: (items, date, completedCount, totalCount) {
        if (items.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color:
                          HanaColors.primaryOf(context).withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMedicationRecords,
                      style: HanaTypography.titleMd.copyWith(
                        color: HanaColors.onSurfaceVariantOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/drugs'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addFirstDrugCta),
                    ),
                  ],
                ),
              ),
            ),
          ];
        }

        final now = DateTime.now();
        final localeName = Localizations.localeOf(context).toLanguageTag();
        TodayScheduleItem? upcoming;
        DateTime? upcomingTime;

        final uncompletedItems =
            items.where((item) => !item.isCompleted).toList();
        for (final item in uncompletedItems) {
          for (final dateTime in item.scheduledDateTimes) {
            if (!dateTime.isAfter(now)) continue;
            if (upcomingTime == null || dateTime.isBefore(upcomingTime)) {
              upcomingTime = dateTime;
              upcoming = item;
            }
          }
        }

        upcoming ??=
            uncompletedItems.isNotEmpty ? uncompletedItems.first : null;
        upcomingTime ??= upcoming?.scheduledDateTimes.firstOrNull ??
            DateTime.now().add(const Duration(hours: 1));

        final widgets = <Widget>[];
        final countdownDrug = upcoming ?? items.first;
        final countdownDosage = '${countdownDrug.schedule.dosageAmount}'
            '${countdownDrug.schedule.dosageUnit.localizedName(l10n)}';

        widgets.addAll([
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: CountdownCard(
                nextScheduledTime: upcomingTime,
                isCompleteForToday: uncompletedItems.isEmpty,
                drugName: countdownDrug.drug.name,
                dosage: countdownDosage,
                route: countdownDrug.schedule.administrationRoute
                    .localizedName(l10n),
                nextDoseLabel: l10n.nextDose,
                completedLabel: l10n.todayCompleted,
                hourUnitLabel: l10n.hourUnit,
                minuteUnitLabel: l10n.minuteUnit,
                onConfirm: () {
                  context.read<TodayScheduleBloc>().add(
                        LogDoseTodaySchedule(
                          drug: countdownDrug.drug,
                          schedule: countdownDrug.schedule,
                          scheduledDateTime:
                              countdownDrug.scheduledDateTimes.firstOrNull,
                        ),
                      );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]);

        String dosageLabel(TodayScheduleItem item) {
          return '${item.schedule.dosageAmount}'
              '${item.schedule.dosageUnit.localizedName(l10n)}';
        }

        String timeLabel(DateTime? dateTime) {
          if (dateTime == null) return l10n.allDay;
          return DateFormat.Hm(localeName).format(dateTime);
        }

        final completedItems = items.where((item) => item.isCompleted).toList();
        if (completedItems.isNotEmpty) {
          widgets.addAll([
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: HoyoSectionTitle(
                  title: l10n.takenDoses,
                  subtitle: '${completedItems.length} / ${items.length}',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final item = completedItems[i];
                  final firstTime = item.scheduledDateTimes.firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: HoyoMedRow(
                      name: item.drug.name,
                      meta: '${timeLabel(firstTime)} · ${dosageLabel(item)}',
                      tone: i.isOdd ? HoyoMedTone.lavender : HoyoMedTone.pink,
                    ),
                  );
                },
                childCount: completedItems.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
          ]);
        }

        if (uncompletedItems.isNotEmpty) {
          widgets.addAll([
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: HoyoSectionTitle(
                  title: l10n.pendingDoses,
                  subtitle: '${uncompletedItems.length}',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final item = uncompletedItems[i];
                  final firstTime = item.scheduledDateTimes.firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                    child: HoyoMedRow(
                      name: item.drug.name,
                      meta: '${timeLabel(firstTime)} · ${dosageLabel(item)}',
                      tone: HoyoMedTone.coral,
                      icon: Icons.medication_outlined,
                      completed: false,
                      onTap: () {
                        context.read<TodayScheduleBloc>().add(
                              LogDoseTodaySchedule(
                                drug: item.drug,
                                schedule: item.schedule,
                                scheduledDateTime: firstTime,
                              ),
                            );
                      },
                    ),
                  );
                },
                childCount: uncompletedItems.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
          ]);
        }

        // Daily 花笺 signature card.
        if (hasHrtStartDate)
          widgets.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: _DailyHanaSection(
                  day: hrtDays.clamp(1, 365),
                  collected: hrtDays.clamp(0, 365),
                  signatureChar: signatureChar,
                ),
              ),
            ),
          );

        return widgets;
      },
    );
  }

  String _greetingForHour(int hour, AppLocalizations l10n) {
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  String _signatureCharFromName(String name) {
    if (name.isEmpty) return '·';
    return name.characters.first.toUpperCase();
  }
}

/// Loads the flower almanac asynchronously and renders the Daily 花笺
/// card. Falls back to a placeholder Container while loading.
class _DailyHanaSection extends StatefulWidget {
  const _DailyHanaSection({
    required this.day,
    required this.collected,
    required this.signatureChar,
  });

  final int day;
  final int collected;
  final String signatureChar;

  @override
  State<_DailyHanaSection> createState() => _DailyHanaSectionState();
}

class _DailyHanaSectionState extends State<_DailyHanaSection> {
  Future<FlowerAlmanac>? _future;

  @override
  void initState() {
    super.initState();
    _future = FlowerAlmanac.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlowerAlmanac>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: HanaColors.surfaceContainerLowOf(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.3),
              ),
            ),
          );
        }
        final almanac = snap.data!;
        final flower = almanac.forDay(widget.day);
        return HanaDailyCard(
          day: widget.day,
          flower: flower,
          collected: widget.collected,
          totalDays: almanac.totalDays,
          signatureChar: widget.signatureChar,
          onShare: () => context.push('/share-poster'),
        );
      },
    );
  }
}
