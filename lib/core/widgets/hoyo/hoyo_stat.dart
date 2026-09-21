// HoYo · Stat capsule with 4-corner gold ticks.
// Mirrors hoyo.css `.hoyo-stat` — used inside plum heroes (Today,
// Profile identity, Data E2 hero).
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoStat extends StatelessWidget {
  const HoyoStat({
    required this.label,
    required this.value,
    super.key,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: HanaColorsV2.pearl.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: HanaColorsV2.goldLight.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: HanaTypography.labelSm.copyWith(
                  color: HanaColorsV2.pearl.withValues(alpha: 0.7),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: HanaTypography.headlineMd.copyWith(
                      color: HanaColorsV2.pearl,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.22,
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit!,
                      style: HanaTypography.labelSm.copyWith(
                        color: HanaColorsV2.pearl.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        // 4 corner ticks (top-left, bottom-right gold L-marks).
        const Positioned(top: -1, left: -1, child: _Tick(corner: _Corner.tl)),
        const Positioned(
          bottom: -1,
          right: -1,
          child: _Tick(corner: _Corner.br),
        ),
      ],
    );
  }
}

enum _Corner { tl, br }

class _Tick extends StatelessWidget {
  const _Tick({required this.corner});

  final _Corner corner;

  @override
  Widget build(BuildContext context) {
    final color = HanaColorsV2.goldLight.withValues(alpha: 0.7);
    final isTl = corner == _Corner.tl;
    return SizedBox(
      width: 8,
      height: 8,
      child: CustomPaint(
        painter: _TickPainter(color: color, isTl: isTl),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({required this.color, required this.isTl});

  final Color color;
  final bool isTl;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    if (isTl) {
      canvas
        ..drawLine(Offset.zero, Offset(size.width, 0), p)
        ..drawLine(Offset.zero, Offset(0, size.height), p);
    } else {
      canvas
        ..drawLine(
          Offset(size.width, 0),
          Offset(size.width, size.height),
          p,
        )
        ..drawLine(
          Offset(0, size.height),
          Offset(size.width, size.height),
          p,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) =>
      old.color != color || old.isTl != isTl;
}
