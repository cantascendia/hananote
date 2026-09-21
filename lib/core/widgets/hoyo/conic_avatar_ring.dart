// HoYo · Conic-gradient avatar ring (Profile + share poster).
// Uses SweepGradient to render a 360° gold→pink→lavender→gold halo.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class ConicAvatarRing extends StatelessWidget {
  const ConicAvatarRing({
    required this.label,
    super.key,
    this.size = 84,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          // Outer conic ring (slightly larger).
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: 3.84, // 220°
                  endAngle: 10.12, // 220° + 360°
                  colors: [
                    Color(0xFFE8C887),
                    Color(0xFFFFB7C5),
                    Color(0xFFC892B0),
                    Color(0xFFE8C887),
                  ],
                ),
              ),
            ),
          ),
          // Inner avatar disc.
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE8EE), Color(0xFFFCD3FB)],
                ),
                border: Border.all(
                  color: HanaColorsV2.plumDeep,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: HanaTypography.headlineLg.copyWith(
                  color: const Color(0xFF864E5A),
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.36,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
