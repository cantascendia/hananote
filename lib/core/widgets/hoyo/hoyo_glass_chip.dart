// HoYo · Sub-pill glass chip — used inside plum hero panels to hold
// metadata (drug name, scheduled time, etc.). Mirrors hoyo.css
// `.hoyo-glass`.
// ignore_for_file: public_member_api_docs

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoGlassChip extends StatelessWidget {
  const HoyoGlassChip({
    required this.label,
    super.key,
    this.icon,
    this.iconColor,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: HanaColorsV2.pearl.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: HanaColorsV2.goldLight.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: iconColor ?? HanaColorsV2.goldLight,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: HanaTypography.labelSm.copyWith(
                  color: HanaColorsV2.pearl,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
