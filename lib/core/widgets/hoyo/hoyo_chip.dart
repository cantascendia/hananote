// HoYo · Chip — pill 9999px radius with 3 tones.
// Mirrors preview/15-chips.html.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

enum HoyoChipTone { primary, secondary, champagne }

class HoyoChip extends StatelessWidget {
  const HoyoChip({
    required this.label,
    super.key,
    this.tone = HoyoChipTone.primary,
    this.icon,
    this.onTap,
  });

  final String label;
  final HoyoChipTone tone;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _resolve(context);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: HanaTypography.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.22,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: chip,
    );
  }

  (Color bg, Color fg, Color border) _resolve(BuildContext c) {
    switch (tone) {
      case HoyoChipTone.primary:
        return (
          HanaColors.primaryContainerOf(c),
          HanaColors.onPrimaryContainerOf(c),
          HanaColorsV2.goldLight.withValues(alpha: 0.4),
        );
      case HoyoChipTone.secondary:
        return (
          HanaColors.secondaryContainerOf(c),
          const Color(0xFF78587A),
          HanaColorsV2.goldLight.withValues(alpha: 0.3),
        );
      case HoyoChipTone.champagne:
        return (
          HanaColorsV2.champagneSoftOf(c),
          HanaColorsV2.goldDeep,
          HanaColorsV2.goldLight.withValues(alpha: 0.4),
        );
    }
  }
}
