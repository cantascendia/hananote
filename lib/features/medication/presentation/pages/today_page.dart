// ignore_for_file: lines_longer_than_80_chars
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/core/widgets/petal_celebration.dart';
import 'package:hananote/features/medication/domain/usecases/get_today_schedule.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_bloc.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_event.dart';
import 'package:hananote/features/medication/presentation/bloc/today_schedule_state.dart';
import 'package:hananote/features/medication/presentation/widgets/countdown_card.dart';
import 'package:hananote/features/medication/presentation/widgets/medication_status_card.dart';
import 'package:hananote/features/medication/presentation/widgets/quote_card.dart';
import 'package:hananote/features/medication/presentation/widgets/upcoming_dose_card.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hananote/features/settings/presentation/bloc/settings_state.dart';
import 'package:intl/intl.dart';

/// The main dashboard page for the current day's health tracking.
class TodayPage extends StatelessWidget {
  /// Creates a [TodayPage].
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    void showComingSoon(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    final settingsState = context.watch<SettingsBloc>().state;
    final displayName = settingsState is SettingsLoaded
        ? settingsState.profile.displayName
        : l10n.defaultUserName;
    final hrtDays =
        settingsState is SettingsLoaded ? settingsState.profile.hrtDayCount : 0;
    final greeting = _greetingForHour(DateTime.now().hour, l10n);

    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      body: BlocListener<TodayScheduleBloc, TodayScheduleState>(
        listenWhen: (previous, current) {
          final prevCompleted = previous.whenOrNull(
            loaded: (_, __, completedCount, ___) => completedCount,
          );
          final currCompleted = current.whenOrNull(
            loaded: (_, __, completedCount, ___) => completedCount,
          );
          return prevCompleted != null &&
              currCompleted != null &&
              currCompleted > prevCompleted;
        },
        listener: (context, state) {
          PetalCelebration.show(context);
        },
        child: BlocBuilder<TodayScheduleBloc, TodayScheduleState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor:
                    HanaColors.backgroundOf(context).withAlpha((255 * 0.8).round()),
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: HanaColors.primaryOf(context),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HanaColors.primaryOf(context),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: HanaColors.primaryOf(context),
                    ),
                    onPressed: () => context.go('/timeline'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting，$displayName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'PlusJakartaSans',
                                color: HanaColors.primaryOf(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.hrtDay(hrtDays),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: HanaColors.onSurfaceVariantOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: HanaColors.primaryContainerOf(context)
                                    .withAlpha((255 * 0.3).round()),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: HanaColors.primaryContainerOf(context),
                              child: Icon(
                                Icons.person,
                                color: HanaColors.onPrimaryContainerOf(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              ..._buildStateContent(context, state, theme, l10n),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return state.when(
      initial: () => [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      loading: () => [
        const SliverFillRemaining(
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
                Text(message, style: TextStyle(color: HanaColors.errorOf(context))),
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
                      color: HanaColors.primaryOf(context).withAlpha(77),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMedicationRecords,
                      style: theme.textTheme.titleMedium?.copyWith(
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
            if (!dateTime.isAfter(now)) {
              continue;
            }
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CountdownCard(
                nextScheduledTime: upcomingTime,
                isCompleteForToday: uncompletedItems.isEmpty,
                drugName: countdownDrug.drug.name,
                dosage: countdownDosage,
                route: countdownDrug.schedule.administrationRoute.localizedName(
                  l10n,
                ),
                nextDoseLabel: l10n.nextDose,
                completedLabel: l10n.todayCompleted,
                hourUnitLabel: l10n.hourUnit,
                minuteUnitLabel: l10n.minuteUnit,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]);

        String dosageLabel(TodayScheduleItem item) {
          return '${item.schedule.dosageAmount}'
              '${item.schedule.dosageUnit.localizedName(l10n)}';
        }

        String timeLabel(DateTime? dateTime) {
          if (dateTime == null) {
            return l10n.allDay;
          }
          return DateFormat.Hm(localeName).format(dateTime);
        }

        final completedItems = items.where((item) => item.isCompleted).toList();
        if (completedItems.isNotEmpty) {
          widgets.addAll([
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.takenDoses,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HanaColors.onSurfaceOf(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: HanaColors.secondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.completedDose.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: HanaColors.onSurfaceVariantOf(context)
                            .withAlpha((255 * 0.6).round()),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: completedItems.map((item) {
                    final firstTime = item.scheduledDateTimes.firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MedicationStatusCard(
                        name: item.drug.name,
                        dosage: dosageLabel(item),
                        time: timeLabel(firstTime),
                        isTaken: true,
                        accentColor: HanaColors.primaryFixedOf(context),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ]);
        }

        if (uncompletedItems.isNotEmpty) {
          widgets.addAll([
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      l10n.pendingDoses,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HanaColors.onSurfaceOf(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HanaColors.tertiaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: uncompletedItems.map((item) {
                    final firstTime = item.scheduledDateTimes.firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: UpcomingDoseCard(
                        name: item.drug.name,
                        dosage: dosageLabel(item),
                        time: timeLabel(firstTime),
                        period: l10n.allDay,
                        takeLabel: l10n.takeDose,
                        onTake: () {
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
                  }).toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ]);
        }

        widgets.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: QuoteCard(
                quote: _quoteForToday(l10n),
              ),
            ),
          ),
        );

        return widgets;
      },
    );
  }

  String _greetingForHour(int hour, AppLocalizations l10n) {
    if (hour < 12) {
      return l10n.goodMorning;
    }
    if (hour < 18) {
      return l10n.goodAfternoon;
    }
    return l10n.goodEvening;
  }

  String _quoteForToday(AppLocalizations l10n) {
    final quotes = [
      l10n.dailyQuote0,
      l10n.dailyQuote1,
      l10n.dailyQuote2,
      l10n.dailyQuote3,
      l10n.dailyQuote4,
      l10n.dailyQuote5,
      l10n.dailyQuote6,
      l10n.dailyQuote7,
      l10n.dailyQuote8,
      l10n.dailyQuote9,
      l10n.dailyQuote10,
      l10n.dailyQuote11,
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
}
