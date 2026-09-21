// HoYo · Gold-flecked petal celebration variant.
// Layers gold flecks (star_bright + gold_light particles) on top of a
// petal cloud + gold ring expansion. Triggered ~10% on dose confirm
// (vs the standard pink-only petal celebration).
//
// Public API matches the simpler `petal_celebration` widget so it can
// be a drop-in replacement when the random gate selects "gold".
// ignore_for_file: public_member_api_docs

import 'dart:math' show Random, cos, pi, sin;

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';

class GoldPetalCelebration extends StatefulWidget {
  const GoldPetalCelebration({
    required this.onComplete,
    super.key,
    this.particleCount = 28,
    this.duration = const Duration(milliseconds: 1600),
  });

  final VoidCallback onComplete;
  final int particleCount;
  final Duration duration;

  @override
  State<GoldPetalCelebration> createState() => _GoldPetalCelebrationState();
}

class _GoldPetalCelebrationState extends State<GoldPetalCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _parts;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    final rng = Random();
    _parts = List.generate(
      widget.particleCount,
      (i) => _Particle.spawn(rng, i, widget.particleCount),
    );
    _ctrl
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _GoldPaint(t: _ctrl.value, parts: _parts),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.gold,
  });

  factory _Particle.spawn(Random rng, int i, int total) {
    final angle = (i / total) * 2 * pi + rng.nextDouble() * 0.5;
    return _Particle(
      angle: angle,
      distance: 90.0 + rng.nextDouble() * 80,
      size: 3.0 + rng.nextDouble() * 4,
      delay: rng.nextDouble() * 0.3,
      gold: rng.nextBool(),
    );
  }

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final bool gold;
}

class _GoldPaint extends CustomPainter {
  _GoldPaint({required this.t, required this.parts});

  final double t;
  final List<_Particle> parts;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Gold ring expansion (the signature of the gold variant).
    final ringT = (t * 1.2).clamp(0.0, 1.0);
    final ringR = ringT * 160;
    final ringPaint = Paint()
      ..color = HanaColorsV2.goldLight.withValues(alpha: (1 - ringT) * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), ringR, ringPaint);

    // Particles.
    for (final p in parts) {
      final localT = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final r = p.distance * Curves.easeOut.transform(localT);
      final alpha = (1 - localT).clamp(0.0, 1.0);
      final color = p.gold
          ? HanaColorsV2.goldLight.withValues(alpha: alpha)
          : const Color(0xFFFFB7C5).withValues(alpha: alpha);
      final paint = Paint()..color = color;
      final dx = cx + cos(p.angle) * r;
      final dy = cy + sin(p.angle) * r;
      canvas.drawCircle(Offset(dx, dy), p.size * (1 - localT * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldPaint old) => old.t != t;
}
