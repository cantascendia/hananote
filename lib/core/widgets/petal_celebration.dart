import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';

/// A sakura-petal particle effect overlay that auto-dismisses after ~1.2 s.
///
/// Call [PetalCelebration.show] to display the effect anchored to the full
/// screen. Petals float downward with a gentle sine-wave wobble and fade out
/// over the animation duration.
class PetalCelebration extends StatefulWidget {
  /// Creates a [PetalCelebration].
  const PetalCelebration({required this.onDone, super.key});

  /// Called when the animation completes so the overlay entry can be removed.
  final VoidCallback onDone;

  /// Shows the petal celebration as a full-screen overlay.
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => PetalCelebration(
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<PetalCelebration> createState() => _PetalCelebrationState();
}

class _PetalCelebrationState extends State<PetalCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Petal> _petals;

  static const _duration = Duration(milliseconds: 1200);
  static const _petalCount = 10;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _petals = List.generate(_petalCount, (_) => _Petal.random(rng));
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDone();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.sizeOf(context),
            painter: _PetalPainter(
              progress: _controller.value,
              petals: _petals,
            ),
          );
        },
      ),
    );
  }
}

/// Data for a single petal particle.
class _Petal {
  _Petal({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.wobbleAmplitude,
    required this.wobbleFrequency,
    required this.rotation,
    required this.rotationSpeed,
    required this.colorIndex,
  });

  factory _Petal.random(Random rng) {
    return _Petal(
      startX: rng.nextDouble(),
      startY: -0.05 - rng.nextDouble() * 0.15,
      size: 6.0 + rng.nextDouble() * 6.0,
      speed: 0.4 + rng.nextDouble() * 0.4,
      wobbleAmplitude: 0.02 + rng.nextDouble() * 0.04,
      wobbleFrequency: 2.0 + rng.nextDouble() * 3.0,
      rotation: rng.nextDouble() * 2 * pi,
      rotationSpeed: (rng.nextDouble() - 0.5) * 4.0,
      colorIndex: rng.nextInt(2),
    );
  }

  final double startX;
  final double startY;
  final double size;

  /// Vertical travel speed multiplier (fraction of screen height per full
  /// animation cycle).
  final double speed;
  final double wobbleAmplitude;
  final double wobbleFrequency;
  final double rotation;
  final double rotationSpeed;

  /// 0 = primaryContainer, 1 = secondaryContainer.
  final int colorIndex;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter({required this.progress, required this.petals});

  final double progress;
  final List<_Petal> petals;

  static const _colors = [
    HanaColors.primaryContainer, // #FFB7C5
    HanaColors.secondaryContainer, // #FCD3FB
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Global opacity: fade out over the last 40% of the animation.
    final opacity = progress < 0.6 ? 1.0 : 1.0 - ((progress - 0.6) / 0.4);

    for (final petal in petals) {
      final x = size.width * petal.startX +
          sin(progress * petal.wobbleFrequency * 2 * pi) *
              size.width *
              petal.wobbleAmplitude;
      final y = size.height * petal.startY +
          progress * size.height * petal.speed;

      final angle = petal.rotation + progress * petal.rotationSpeed;

      final paint = Paint()
        ..color = _colors[petal.colorIndex]
            .withValues(alpha: opacity * 0.85)
        ..style = PaintingStyle.fill;

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(angle);

      // Draw a simple petal shape (ellipse).
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: petal.size,
        height: petal.size * 1.6,
      );
      canvas
        ..drawOval(rect, paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
