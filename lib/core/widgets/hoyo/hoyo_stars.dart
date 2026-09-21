// HoYo · Star particles (twinkling decoration overlay).
// Mirrors hoyo.css `.hoyo-stars` — two layers of radial-gradient
// pseudo-stars, alternating opacity at 6s + 4s reverse.
//
// Uses two AnimatedOpacity layers for cheap GPU-friendly twinkling.
// Constrained inside RepaintBoundary so it doesn't repaint parent.
//
// ignore_for_file: public_member_api_docs

import 'dart:math' show Random;

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';

class HoyoStars extends StatefulWidget {
  const HoyoStars({
    super.key,
    this.density = 1.0,
    this.borderRadius,
  });

  /// Density multiplier (default 1.0 = ~12 stars).
  final double density;
  final BorderRadius? borderRadius;

  @override
  State<HoyoStars> createState() => _HoyoStarsState();
}

class _HoyoStarsState extends State<HoyoStars> with TickerProviderStateMixin {
  late final AnimationController _ctrlA = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  late final AnimationController _ctrlB = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final List<_Star> _layerA;
  late final List<_Star> _layerB;

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    final n = (12 * widget.density).round();
    _layerA = List.generate(n, (_) => _Star.random(rng));
    _layerB = List.generate((n * 0.6).round(), (_) => _Star.random(rng));
  }

  @override
  void dispose() {
    _ctrlA.dispose();
    _ctrlB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _ctrlA,
              builder: (_, __) => CustomPaint(
                painter: _StarsPainter(
                  _layerA,
                  // 0.35 → 0.9 → 0.55 across t=0..1 (matches keyframes)
                  opacity: _easeOpacity(_ctrlA.value),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _ctrlB,
              builder: (_, __) => CustomPaint(
                painter: _StarsPainter(
                  _layerB,
                  opacity: _easeOpacity(_ctrlB.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _easeOpacity(double t) {
    // 0 → .35, .5 → .9, 1 → .55
    if (t < 0.5) {
      return 0.35 + (0.9 - 0.35) * (t * 2);
    }
    return 0.9 - (0.9 - 0.55) * ((t - 0.5) * 2);
  }
}

class _Star {
  _Star({
    required this.dx,
    required this.dy,
    required this.r,
    required this.color,
  });

  factory _Star.random(Random rng) {
    final palette = <Color>[
      HanaColorsV2.starBright,
      HanaColorsV2.starMid,
      const Color(0xFFFFE8EE),
    ];
    return _Star(
      dx: rng.nextDouble(),
      dy: rng.nextDouble(),
      r: 0.7 + rng.nextDouble() * 1.4,
      color: palette[rng.nextInt(palette.length)],
    );
  }

  final double dx;
  final double dy;
  final double r;
  final Color color;
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.stars, {required this.opacity});

  final List<_Star> stars;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final paint = Paint()
        ..color = s.color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) =>
      old.opacity != opacity || old.stars != stars;
}
