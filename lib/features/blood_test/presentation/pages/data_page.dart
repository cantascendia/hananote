// ignore_for_file: lines_longer_than_80_chars
// Release prep note: This page keeps a few dense sections simple while the
// blood test editor flow is being connected.
// ignore_for_file: public_member_api_docs

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/features/blood_test/domain/entities/blood_test_report.dart';
import 'package:hananote/features/blood_test/domain/entities/enums.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_bloc.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_event.dart';
import 'package:hananote/features/blood_test/presentation/bloc/blood_test_state.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      extendBodyBehindAppBar: true,
      appBar: HoyoAppBar(
        title: l10n.dataAndTrends,
        leading: IconButton(
          icon: Icon(
            Symbols.notifications,
            size: 18,
            color: HanaColors.primaryOf(context),
          ),
          onPressed: () => context.push('/settings'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Symbols.add_circle,
              size: 18,
              color: HanaColors.primaryOf(context),
            ),
            onPressed: () => context.push('/data/add_report'),
          ),
        ],
      ),
      body: BlocBuilder<BloodTestBloc, BloodTestState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const SizedBox.shrink(),
            loading: (_) => const Center(
              child: CircularProgressIndicator(color: HanaColors.primary),
            ),
            error: (error) => Center(child: Text(error.message)),
            loaded: (loaded) => _LoadedView(
              state: loaded,
              topPadding: topPadding,
            ),
          );
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.state,
    required this.topPadding,
  });

  final BloodTestLoaded state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('yyyy.MM.dd');
    final lastUpdatedText = state.lastUpdated == null
        ? l10n.noUpdatesYet
        : l10n.lastUpdated(dateFormat.format(state.lastUpdated!));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.myStatus,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
              ),
              Text(
                lastUpdatedText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: HanaColors.onSurfaceVariant
                          .withAlpha((255 * 0.6).round()), // 60%
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bodyChanging,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HanaColors.primary.withAlpha(204), // 80%
                ),
          ),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: state.latestReadings.values.map((reading) {
              final status = reading.type.statusFor(reading.value);
              final valueNumber = reading.value.toStringAsFixed(1);
              final unitText = reading.type.defaultUnit;

              final isWarning = status != HormoneStatus.normal;

              return _StitchHormoneCard(
                name: reading.type.localizedName(l10n),
                value: valueNumber,
                unit: unitText,
                subtitle: status.localizedName(l10n),
                statusColor: switch (status) {
                  HormoneStatus.normal => HanaColors.statusGreen,
                  HormoneStatus.warning => HanaColors.tertiary,
                  HormoneStatus.critical => HanaColors.error,
                },
                bgIcon: isWarning
                    ? Symbols.warning_amber_rounded
                    : Symbols.water_drop,
                onTap: () {
                  context.read<BloodTestBloc>().add(
                        SelectHormoneForTrend(reading.type),
                      );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          // Simulator Card
          _StitchSimulatorCard(onTap: () => context.push('/data/simulator')),

          const SizedBox(height: 16),
          // Knowledge Base Card
          _StitchKnowledgeCard(onTap: () => context.push('/knowledge')),

          const SizedBox(height: 32),
          // Trends Section Placeholder
          Text(
            l10n.trendSection,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: HanaColors.primary,
                  fontFamily: 'Plus Jakarta Sans',
                ),
          ),
          const SizedBox(height: 16),
          _TrendChart(
            reports: state.reports,
            selectedHormone: state.selectedTrendHormone,
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.historyReports,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: HanaColors.primary,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.reports.isEmpty)
            _EmptyHistoryCard(label: l10n.noBloodTestHistory)
          else
            ...state.reports.map((report) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StitchHistoryCard(
                  report: report,
                  localeName: localeName,
                  onTap: () => context.push('/data/add_report?id=${report.id}'),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StitchHormoneCard extends StatefulWidget {
  const _StitchHormoneCard({
    required this.name,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.statusColor,
    required this.bgIcon,
    required this.onTap,
  });

  final String name;
  final String value;
  final String unit;
  final String subtitle;
  final Color statusColor;
  final IconData bgIcon;
  final VoidCallback onTap;

  @override
  State<_StitchHormoneCard> createState() => _StitchHormoneCardState();
}

class _StitchHormoneCardState extends State<_StitchHormoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.statusColor.withAlpha(77), // 30%
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.statusColor.withAlpha(26), // 10%
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Icon
              Positioned(
                right: -16,
                bottom: -16,
                child: Icon(
                  widget.bgIcon,
                  size: 96,
                  color: widget.statusColor.withAlpha(26), // 10%
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HanaColors.onSurfaceVariant
                                  .withAlpha((255 * 0.8).round()), // 80%
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withAlpha(26), // 10%
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: HanaColors.primary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.unit,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: HanaColors.onSurfaceVariant
                                .withAlpha(153), // 60%
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StitchSimulatorCard extends StatelessWidget {
  const _StitchSimulatorCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                HanaColors.primaryContainer,
                HanaColors.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: HanaColors.primaryContainer.withAlpha(77), // 30%
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(128), // 50%
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Symbols.science, color: HanaColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pkSimulatorTitle,
                      style: const TextStyle(
                        color: HanaColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pkSimulatorSubtitle,
                      style: TextStyle(
                        color: HanaColors.primary.withAlpha(153), // 60%
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(128), // 50%
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.arrow_forward_ios,
                  color: HanaColors.primary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StitchKnowledgeCard extends StatelessWidget {
  const _StitchKnowledgeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                HanaColors.primaryContainer,
                HanaColors.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: HanaColors.primaryContainer.withAlpha(77), // 30%
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(128), // 50%
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Symbols.menu_book_rounded,
                  color: HanaColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.knowledgeBase,
                      style: const TextStyle(
                        color: HanaColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.knowledgeBaseSubtitle,
                      style: TextStyle(
                        color: HanaColors.primary.withAlpha(153), // 60%
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(128), // 50%
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.arrow_forward_ios,
                  color: HanaColors.primary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.reports,
    required this.selectedHormone,
  });

  final List<BloodTestReport> reports;
  final HormoneType selectedHormone;

  List<({DateTime date, double value})> _extractPoints() {
    final points = <({DateTime date, double value})>[];
    for (final report in reports) {
      for (final reading in report.readings) {
        if (reading.type == selectedHormone) {
          points.add((date: report.testDate, value: reading.value));
          break;
        }
      }
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final points = _extractPoints();
    final hasTrendData = points.length >= 2;
    final currentUnit = selectedHormone.defaultUnit;
    final trendLabel =
        hasTrendData && points.last.value < points[points.length - 2].value
            ? l10n.trendDecreasing
            : l10n.trendStable;

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final minValue = hasTrendData
        ? points.map((point) => point.value).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxValue = hasTrendData
        ? points.map((point) => point.value).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final chartMinY = hasTrendData
        ? (minValue * 0.9).clamp(0, double.infinity).toDouble()
        : 0.0;
    final chartMaxY = hasTrendData
        ? (maxValue * 1.1).clamp(10, double.infinity).toDouble()
        : 100.0;
    final yInterval = hasTrendData
        ? ((chartMaxY - chartMinY) / 3).clamp(1, double.infinity).toDouble()
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: HanaColors.primary.withAlpha(10), // 4%
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HanaColors.primaryContainer.withAlpha(128), // 50%
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Symbols.trending_up,
                      color: HanaColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    trendLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: HanaColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: HanaColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.lastHalfYear,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HanaColors.onSurfaceVariant
                            .withAlpha((255 * 0.8).round()),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.keyboard_arrow_down,
                      size: 14,
                      color: HanaColors.onSurfaceVariant
                          .withAlpha((255 * 0.8).round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: hasTrendData
                ? LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (points.length - 1).toDouble(),
                      minY: chartMinY,
                      maxY: chartMaxY,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: HanaColors.outlineVariant.withAlpha(90),
                          strokeWidth: 1,
                          dashArray: const [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 56,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) => SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${value.toStringAsFixed(0)} $currentUnit',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: HanaColors.onSurfaceVariant
                                      .withAlpha((255 * 0.8).round()),
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  DateFormat('MM/dd', localeName)
                                      .format(points[index].date),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: HanaColors.onSurfaceVariant
                                        .withAlpha((255 * 0.8).round()),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: HanaColors.primary,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                HanaColors.primary.withAlpha(51),
                                HanaColors.primary.withAlpha(0),
                              ],
                            ),
                          ),
                          dotData: FlDotData(
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: HanaColors.primary,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.show_chart,
                          size: 48,
                          color: HanaColors.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noTrendData,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: HanaColors.onSurfaceVariant.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StitchHistoryCard extends StatefulWidget {
  const _StitchHistoryCard({
    required this.report,
    required this.localeName,
    required this.onTap,
  });

  final BloodTestReport report;
  final String localeName;
  final VoidCallback onTap;

  @override
  State<_StitchHistoryCard> createState() => _StitchHistoryCardState();
}

class _StitchHistoryCardState extends State<_StitchHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HanaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24), // rounded-3xl
            boxShadow: [
              BoxShadow(
                color:
                    HanaColors.primary.withAlpha(5), // extremely subtle shadow
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HanaColors.primaryContainer.withAlpha(77), // 30%
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Symbols.description, color: HanaColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMd(widget.localeName)
                          .format(widget.report.testDate),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: HanaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.report.readings.take(2).map((reading) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: HanaColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${reading.type.localizedName(l10n)} ${reading.value}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: HanaColors.onSurfaceVariant
                                  .withAlpha((255 * 0.8).round()),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Symbols.chevron_right,
                  color: HanaColors.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HanaColors.outlineVariant.withAlpha(26)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HanaColors.onSurfaceVariant,
            ),
      ),
    );
  }
}
