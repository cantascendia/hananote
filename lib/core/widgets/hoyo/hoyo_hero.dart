// HoYo · Hero card chassis — plum twilight gradient with star particles
// and a sakura halo. Mirrors hoyo.css `.hoyo-hero`.
//
// Provides a pre-baked `Theme` extension that overrides text color
// to pearl so descendants need not pass white explicitly.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_stars.dart';

class HoyoHero extends StatelessWidget {
  const HoyoHero({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(22, 24, 22, 24),
    this.borderRadius = 28,
    this.stars = true,
    this.halo = true,
    this.height,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool stars;
  final bool halo;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: HanaGradientsV2.heroNight,
        borderRadius: radius,
        boxShadow: HanaShadowsV2.glowPlum,
      ),
      child: Stack(
        children: [
          // Sakura halo (top-right blur puck) — Positioned, painted first.
          if (halo)
            Positioned(
              top: -40,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: HanaGradientsV2.petalHalo,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          // Twinkling star particles (Positioned.fill — depends on
          // the Stack having a size, which the body below provides).
          if (stars)
            Positioned.fill(
              child: IgnorePointer(child: HoyoStars(borderRadius: radius)),
            ),
          // Gold hairline overlay (Positioned.fill, on top of stars).
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HeroHairlinePainter(borderRadius),
              ),
            ),
          ),
          // Body — non-Positioned so it provides the Stack's intrinsic
          // size; placed LAST in children so it paints on top.
          DefaultTextStyle.merge(
            style: const TextStyle(color: HanaColorsV2.pearl),
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class _HeroHairlinePainter extends CustomPainter {
  _HeroHairlinePainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xD8E8C887),
        Color(0x26E8C887),
        Color(0x40FFB7C5),
        Color(0x99E8C887),
      ],
      stops: [0, 0.3, 0.65, 1],
    ).createShader(Offset.zero & size);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroHairlinePainter old) =>
      old.radius != radius;
}
