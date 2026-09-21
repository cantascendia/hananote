// HoYo · Card chassis — 22px radius + gold-hairline frame.
// Mirrors hoyo.css `.hoyo-card` (with optional `.corner-mark`).
//
// The hairline gradient is rendered with a CustomPaint stroke since
// CSS `mask-composite: xor` is not directly supported in Flutter.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/core/widgets/hoyo/corner_mark.dart';

class HoyoCard extends StatelessWidget {
  const HoyoCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
    this.cornerMark = false,
    this.shadow,
    this.background,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool cornerMark;
  final List<BoxShadow>? shadow;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final bg = background ?? HanaColors.surfaceContainerLowestOf(context);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        boxShadow: shadow ?? HanaShadowsV2.cardElevated,
      ),
      child: Stack(
        children: [
          // Gold hairline border via CustomPaint.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HairlinePainter(
                  radius: borderRadius,
                  color: HanaColorsV2.goldLight,
                ),
              ),
            ),
          ),
          if (cornerMark)
            const Positioned(
              right: 12,
              top: 12,
              child: CornerMark(),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _HairlinePainter extends CustomPainter {
  _HairlinePainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.5),
        color.withValues(alpha: 0),
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.35),
      ],
      stops: const [0, 0.35, 0.65, 1],
    ).createShader(Offset.zero & size);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _HairlinePainter old) =>
      old.radius != radius || old.color != color;
}
