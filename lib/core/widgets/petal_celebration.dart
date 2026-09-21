import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';

/// Shows a sakura petal celebration overlay on dose completion.
///
/// Per DESIGN.md: "花瓣散落般的轻微粒子特效"
class PetalCelebration {
  PetalCelebration._();

  /// Shows the petal celebration overlay at the center of the screen.
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _PetalOverlay(
        onComplete: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _PetalOverlay extends StatefulWidget {
  const _PetalOverlay({required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<_PetalOverlay> createState() => _PetalOverlayState();
}

class _PetalOverlayState extends State<_PetalOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    final rng = Random();
    _petals = List.generate(10, (_) => _Petal(rng));
    _controller.forward();
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
            size: MediaQuery.of(context).size,
            painter: _PetalPainter(
              petals: _petals,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Petal {
  _Petal(Random rng)
      : x = rng.nextDouble(),
        startY = 0.3 + rng.nextDouble() * 0.3,
        size = 6 + rng.nextDouble() * 8,
        speed = 0.5 + rng.nextDouble() * 0.5,
        wobbleFreq = 2 + rng.nextDouble() * 3,
        wobbleAmp = 0.02 + rng.nextDouble() * 0.04,
        rotation = rng.nextDouble() * pi * 2,
        rotSpeed = (rng.nextDouble() - 0.5) * 4,
        isPink = rng.nextBool();

  final double x;
  final double startY;
  final double size;
  final double speed;
  final double wobbleFreq;
  final double wobbleAmp;
  final double rotation;
  final double rotSpeed;
  final bool isPink;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter({required this.petals, required this.progress});

  final List<_Petal> petals;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      final t = progress * petal.speed;
      final dx = petal.x * size.width +
          sin(progress * petal.wobbleFreq * pi * 2) *
              petal.wobbleAmp *
              size.width;
      final dy = (petal.startY + t * 0.4) * size.height;

      // Fade out in last 40%
      final opacity =
          progress > 0.6 ? (1.0 - (progress - 0.6) / 0.4).clamp(0.0, 1.0) : 1.0;

      final paint = Paint()
        ..color = (petal.isPink
                ? HanaColors.primaryContainer
                : HanaColors.secondaryContainer)
            .withAlpha((opacity * 200).round())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(petal.rotation + progress * petal.rotSpeed);

      // Draw petal shape (ellipse)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
