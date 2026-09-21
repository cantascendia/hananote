// HanaNote v2 — Plum hero countdown card.
// Replaces the v1 sakura→lavender card with a HoyoHero plum twilight
// panel: gold-text countdown numerals, glass chips for drug/time,
// gold pill for "立即确认服用".
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/gold_text.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_glass_chip.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_hero.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';

/// A card displaying the countdown to the next medication dose.
class CountdownCard extends StatefulWidget {
  /// Creates a [CountdownCard].
  const CountdownCard({
    required this.drugName,
    required this.dosage,
    required this.route,
    required this.nextDoseLabel,
    required this.completedLabel,
    required this.hourUnitLabel,
    required this.minuteUnitLabel,
    this.nextScheduledTime,
    this.isCompleteForToday = false,
    this.onConfirm,
    super.key,
  });

  /// The name of the drug.
  final String drugName;

  /// The dosage amount and unit.
  final String dosage;

  /// The route of administration.
  final String route;

  /// Localized heading above the countdown.
  final String nextDoseLabel;

  /// Localized completion label shown when today's schedule is finished.
  final String completedLabel;

  /// Localized hour unit label.
  final String hourUnitLabel;

  /// Localized minute unit label.
  final String minuteUnitLabel;

  /// The next due time for the reminder.
  final DateTime? nextScheduledTime;

  /// Whether all doses for today are already complete.
  final bool isCompleteForToday;

  /// Triggered when the user taps the gold pill confirmation button.
  final VoidCallback? onConfirm;

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  (int, int) _calculateRemaining() {
    if (widget.isCompleteForToday || widget.nextScheduledTime == null) {
      return (0, 0);
    }
    final diff = widget.nextScheduledTime!.difference(DateTime.now());
    if (diff.isNegative) return (0, 0);
    return (diff.inHours, diff.inMinutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _calculateRemaining();
    final isComplete = widget.isCompleteForToday;

    return HoyoHero(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HoyoEyebrow(
            'NEXT DOSE · ${widget.nextDoseLabel}',
            tone: HoyoEyebrowTone.light,
          ),
          const SizedBox(height: 14),
          if (isComplete)
            GoldText(
              widget.completedLabel,
              style: HanaTypography.headlineLg.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                GoldText(
                  '${remaining.$1}',
                  style: HanaTypography.displayLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 54,
                    letterSpacing: -1.62,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.hourUnitLabel,
                  style: HanaTypography.titleSm.copyWith(
                    color: HanaColorsV2.pearl.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                GoldText(
                  '${remaining.$2}',
                  style: HanaTypography.displayLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 54,
                    letterSpacing: -1.62,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.minuteUnitLabel,
                  style: HanaTypography.titleSm.copyWith(
                    color: HanaColorsV2.pearl.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HoyoGlassChip(
                icon: Icons.medication,
                label: '${widget.drugName} ${widget.dosage}',
              ),
              HoyoGlassChip(
                icon: Icons.schedule,
                label: widget.route,
              ),
            ],
          ),
          if (!isComplete && widget.onConfirm != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: HoyoPillButton(
                label: '立即确认服用',
                icon: Icons.check_circle,
                variant: HoyoPillVariant.gold,
                onPressed: widget.onConfirm,
                expand: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
