// HoYo · Rotating conic halo (used behind E2 numeral on Data tab).
// 360° rotation per 12s; pinned behind a child via Stack.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class ConicHalo extends StatefulWidget {
  const ConicHalo({
    required this.child,
    super.key,
    this.size = 120,
    this.duration = const Duration(seconds: 12),
  });

  final Widget child;
  final double size;
  final Duration duration;

  @override
  State<ConicHalo> createState() => _ConicHaloState();
}

class _ConicHaloState extends State<ConicHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return Transform.rotate(
                angle: _ctrl.value * 2 * 3.14159,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0x33FFB7C5),
                        Color(0x33E8C887),
                        Color(0x33C892B0),
                        Color(0x33FFB7C5),
                      ],
                      stops: [0, 0.33, 0.66, 1],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}
