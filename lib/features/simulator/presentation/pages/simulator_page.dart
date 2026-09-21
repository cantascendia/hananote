// Release prep note: SimulatorPage is a dense experimental screen, so a small
// set of file-level lint suppressions remains until the post-release refactor.
// ignore_for_file: public_member_api_docs
// ignore_for_file: require_trailing_commas
// ignore_for_file: prefer_int_literals
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: sized_box_for_whitespace
// ignore_for_file: omit_local_variable_types
// ignore_for_file: lines_longer_than_80_chars

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/app/di/injection.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_shadows.dart';
import 'package:hananote/core/l10n/arb/app_localizations.dart';
import 'package:hananote/core/l10n/enum_l10n.dart';
import 'package:hananote/features/simulator/domain/entities/dosing_regimen.dart';
import 'package:hananote/features/simulator/domain/entities/ester_type.dart';
import 'package:hananote/features/simulator/domain/entities/pk_result.dart';
import 'package:hananote/features/simulator/presentation/blocs/simulator_bloc.dart';

class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SimulatorBloc>()..add(const SimulatorEvent.started()),
      child: const _SimulatorScan(),
    );
  }
}

class _SimulatorScan extends StatelessWidget {
  const _SimulatorScan();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SimulatorBloc, SimulatorState>(
      builder: (context, state) {
        final isHanaPk = state.maybeMap(
          loaded: (s) => s.isHanaPk,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: HanaColors.background,
          appBar: AppBar(
            title: Text(l10n.pkSimulator),
            backgroundColor: HanaColors.surface,
            actions: [
              if (state.maybeMap(loaded: (_) => true, orElse: () => false))
                Badge(
                  isLabelVisible: isHanaPk,
                  label: const Text('Beta'),
                  backgroundColor: HanaColors.tertiary,
                  child: IconButton(
                    icon: Icon(
                      Icons.science,
                      color: isHanaPk ? HanaColors.primary : HanaColors.outline,
                    ),
                    tooltip: l10n.toggleHanaPkEngine,
                    onPressed: () {
                      context
                          .read<SimulatorBloc>()
                          .add(const SimulatorEvent.engineToggled());
                    },
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            error: (e) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(e.message,
                    style: const TextStyle(color: HanaColors.error)),
              ),
            ),
            loaded: (loaded) => _buildContent(
              context: context,
              regimen: loaded.regimen,
              result: loaded.result,
              hanaPkResult: loaded.hanaPkResult,
              isHanaPk: loaded.isHanaPk,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required DosingRegimen regimen,
    required PkSimulationResult result,
    required PkSimulationResult? hanaPkResult,
    required bool isHanaPk,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ParamsCard(regimen: regimen),
          const SizedBox(height: 16),
          _ChartCard(
            result: result,
            hanaPkResult: hanaPkResult,
            isHanaPk: isHanaPk,
          ),
          const SizedBox(height: 16),
          _SummaryCard(result: result),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              AppLocalizations.of(context)!.simulatorDisclaimer,
              style: const TextStyle(
                color: HanaColors.outline,
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ParamsCard extends StatefulWidget {
  const _ParamsCard({required this.regimen});
  final DosingRegimen regimen;

  @override
  State<_ParamsCard> createState() => _ParamsCardState();
}

class _ParamsCardState extends State<_ParamsCard> {
  late EsterType _esterType;
  late TextEditingController _doseCtrl;
  late TextEditingController _intervalCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _wearCtrl;
  SublingualHoldTime? _holdTime;

  @override
  void initState() {
    super.initState();
    _initFromRegimen(widget.regimen);
  }

  @override
  void didUpdateWidget(covariant _ParamsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't auto-update text if user is typing, but do for ester switches
    if (widget.regimen.esterType != _esterType) {
      _initFromRegimen(widget.regimen);
    }
  }

  void _initFromRegimen(DosingRegimen r) {
    _esterType = r.esterType;
    _doseCtrl = TextEditingController(text: r.doseAmount.toStringAsFixed(1));
    _intervalCtrl =
        TextEditingController(text: r.intervalDays.toStringAsFixed(1));
    _weightCtrl = TextEditingController(
        text: (r.bodyWeightKg ?? 65.0).toStringAsFixed(0));
    _wearCtrl = TextEditingController(
        text: (r.wearDurationDays ?? 7.0).toStringAsFixed(1));
    _holdTime = r.sublingualHoldTime ?? SublingualHoldTime.standard;
  }

  @override
  void dispose() {
    _doseCtrl.dispose();
    _intervalCtrl.dispose();
    _weightCtrl.dispose();
    _wearCtrl.dispose();
    super.dispose();
  }

  void _applyParams() {
    final dose = double.tryParse(_doseCtrl.text) ?? 5.0;
    final interval = double.tryParse(_intervalCtrl.text) ?? 7.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 65.0;
    final wear = double.tryParse(_wearCtrl.text) ?? 7.0;

    final newRegimen = widget.regimen.copyWith(
      esterType: _esterType,
      doseAmount: dose,
      intervalDays: interval,
      bodyWeightKg: weight,
      wearDurationDays: _esterType == EsterType.transdermalPatch ? wear : null,
      sublingualHoldTime:
          _esterType == EsterType.sublingualEstradiol ? _holdTime : null,
    );

    context
        .read<SimulatorBloc>()
        .add(SimulatorEvent.regimenUpdated(regimen: newRegimen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HanaShadows.cardShadow,
      ),
      child: ExpansionTile(
        title: Text(
          l10n.simulatorSchemeParams,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: HanaColors.primary,
          ),
        ),
        subtitle: Text(
          '${_esterType.localizedName(l10n)} · ${_doseCtrl.text}mg / ${_intervalCtrl.text}${l10n.daySuffix.trim()}',
          style:
              const TextStyle(fontSize: 13, color: HanaColors.onSurfaceVariant),
        ),
        initiallyExpanded: false,
        shape: const Border(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<EsterType>(
                  // ignore: deprecated_member_use
                  value: _esterType,
                  decoration: InputDecoration(
                    labelText: l10n.simulatorDrugType,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: EsterType.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.localizedName(l10n)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _esterType = v);
                      _applyParams();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _doseCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.simulatorSingleDose,
                          border: const OutlineInputBorder(),
                        ),
                        // Only apply when done
                        onEditingComplete: _applyParams,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _intervalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.simulatorInterval,
                          border: const OutlineInputBorder(),
                        ),
                        onEditingComplete: _applyParams,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.simulatorWeight,
                          border: const OutlineInputBorder(),
                        ),
                        onEditingComplete: _applyParams,
                      ),
                    ),
                    if (_esterType == EsterType.transdermalPatch) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _wearCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.simulatorPatchWear,
                            border: const OutlineInputBorder(),
                          ),
                          onEditingComplete: _applyParams,
                        ),
                      ),
                    ] else
                      const Spacer(),
                  ],
                ),
                if (_esterType == EsterType.sublingualEstradiol) ...[
                  const SizedBox(height: 16),
                  Text(l10n.simulatorSublingualHold,
                      style: const TextStyle(
                          fontSize: 12, color: HanaColors.outline)),
                  const SizedBox(height: 8),
                  SegmentedButton<SublingualHoldTime>(
                    segments: [
                      ButtonSegment(
                          value: SublingualHoldTime.quick,
                          label: Text(
                              SublingualHoldTime.quick.localizedName(l10n))),
                      ButtonSegment(
                          value: SublingualHoldTime.casual,
                          label: Text(
                              SublingualHoldTime.casual.localizedName(l10n))),
                      ButtonSegment(
                          value: SublingualHoldTime.standard,
                          label: Text(
                              SublingualHoldTime.standard.localizedName(l10n))),
                      ButtonSegment(
                          value: SublingualHoldTime.strict,
                          label: Text(
                              SublingualHoldTime.strict.localizedName(l10n))),
                    ],
                    selected: {_holdTime ?? SublingualHoldTime.standard},
                    onSelectionChanged: (set) {
                      setState(() => _holdTime = set.first);
                      _applyParams();
                    },
                    style: SegmentedButton.styleFrom(
                      foregroundColor: HanaColors.onSurface,
                      selectedForegroundColor: HanaColors.onPrimary,
                      selectedBackgroundColor: HanaColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _applyParams,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HanaColors.primary,
                    foregroundColor: HanaColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.updateSimulation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.result,
    this.hanaPkResult,
    required this.isHanaPk,
  });
  final PkSimulationResult result;
  final PkSimulationResult? hanaPkResult;
  final bool isHanaPk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16).copyWith(
          topLeft: const Radius.circular(16),
        ), // To prevent implicit conversion issues occasionally
        boxShadow: HanaShadows.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.concentrationCurve,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HanaColors.onSurface,
                ),
              ),
              Row(
                children: [
                  _LegendItem(
                    color: isHanaPk ? HanaColors.secondary : HanaColors.primary,
                    label: isHanaPk ? l10n.hanaPkLabel : l10n.v2StandardLabel,
                    isDashed: false,
                  ),
                  const SizedBox(width: 8),
                  if (hanaPkResult != null)
                    _LegendItem(
                      color:
                          isHanaPk ? HanaColors.primary : HanaColors.secondary,
                      label: isHanaPk ? l10n.v2StandardLabel : l10n.hanaPkLabel,
                      isDashed: true,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(_buildChartData(context)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chartAxisLabel,
            style: const TextStyle(fontSize: 11, color: HanaColors.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    // Determine the max X (days) and Y (concentration)
    final mainCurve = result.curvePoints;
    final cmpCurve = hanaPkResult?.curvePoints;

    final maxX = mainCurve.isEmpty ? 90.0 : mainCurve.last.time / 24;
    double getPeak(Iterable<PkCurvePoint> points) =>
        points.fold<double>(0, (m, p) => math.max(m, p.concentration));
    final rawMax = math.max(
      getPeak(mainCurve),
      cmpCurve != null ? getPeak(cmpCurve) : 0.0,
    );
    final maxY = math.max(rawMax * 1.25, 50.0).ceilToDouble();
    final yInterval = math.max(25.0, (maxY / 6).ceilToDouble());

    final primaryColor = isHanaPk ? HanaColors.secondary : HanaColors.primary;
    final compareColor = isHanaPk ? HanaColors.primary : HanaColors.secondary;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: HanaColors.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1.0,
            dashArray: const [4, 4],
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: math.max(1, (maxX / 6).floorToDouble()),
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${value.toInt()}d',
                  style: const TextStyle(
                    color: HanaColors.outline,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: HanaColors.outline,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 100.0,
            color: Colors.green.withValues(alpha: 0.3),
            strokeWidth: 0.0,
            label: HorizontalLineLabel(
              show: false,
            ),
          ),
          HorizontalLine(
            y: 200.0,
            color: Colors.green.withValues(alpha: 0.3),
            strokeWidth: 0.0,
            label: HorizontalLineLabel(
              show: false,
            ),
          ),
        ],
      ),
      rangeAnnotations: RangeAnnotations(
        horizontalRangeAnnotations: [
          HorizontalRangeAnnotation(
            y1: 100.0,
            y2: 200.0,
            color: Colors.green.withValues(alpha: 0.1),
          ),
        ],
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.x.toStringAsFixed(1)}d\n${spot.y.toStringAsFixed(1)} pg/mL',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        // Target Range Guides (Top line)
        LineChartBarData(
          spots: [const FlSpot(0, 200), FlSpot(maxX, 200)],
          isCurved: false,
          color: Colors.green.withValues(alpha: 0.3),
          barWidth: 1.0,
          dotData: const FlDotData(show: false),
        ),
        // Target Range Guides (Bottom line)
        LineChartBarData(
          spots: [const FlSpot(0, 100), FlSpot(maxX, 100)],
          isCurved: false,
          color: Colors.green.withValues(alpha: 0.3),
          barWidth: 1.0,
          dotData: const FlDotData(show: false),
        ),

        // Comparison Curve (dashed)
        if (cmpCurve != null)
          LineChartBarData(
            spots: cmpCurve
                .map<FlSpot>((p) => FlSpot(p.time / 24, p.concentration))
                .toList(),
            isCurved: true,
            color: compareColor.withValues(alpha: 0.5),
            barWidth: 2.0,
            isStrokeCapRound: true,
            dashArray: const [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),

        // Main Curve
        LineChartBarData(
          spots: mainCurve
              .map<FlSpot>((p) => FlSpot(p.time / 24, p.concentration))
              .toList(),
          isCurved: true,
          color: primaryColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.3),
                primaryColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDashed,
  });

  final Color color;
  final String label;
  final bool isDashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 2,
          child: isDashed
              ? Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 2),
                        height: 2,
                        color: color,
                      ),
                    ),
                  ),
                )
              : ColoredBox(color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});
  final PkSimulationResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final avg = result.steadyStateAverage;

    // Status color
    Color statusColor = HanaColors.error;
    IconData statusIcon = Icons.cancel;
    if (avg >= 100 && avg <= 200) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (avg >= 80 && avg < 100 || avg > 200 && avg <= 250) {
      statusColor = Colors.orange;
      statusIcon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HanaShadows.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.steadyStateSummary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: HanaColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                l10n.reachSteadyDays(
                    result.timeToSteadyState.toStringAsFixed(0)),
                style: const TextStyle(
                  fontSize: 12,
                  color: HanaColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatIndicator(
                label: l10n.peakLabel,
                value: result.steadyStatePeak.toStringAsFixed(1),
              ),
              _StatIndicator(
                label: l10n.troughLabel,
                value: result.steadyStateTrough.toStringAsFixed(1),
                color: result.steadyStateTrough < 100 ? Colors.orange : null,
              ),
              _StatIndicator(
                label: l10n.averageLabel,
                value: avg.toStringAsFixed(1),
                color: statusColor,
              ),
              _StatIndicator(
                label: 'AUC',
                value: result.aucPerInterval.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatIndicator extends StatelessWidget {
  const _StatIndicator({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? HanaColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: HanaColors.outline,
          ),
        ),
      ],
    );
  }
}
