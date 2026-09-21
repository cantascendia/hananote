// HoYo · Med-row card — pill-icon disc + name/meta + status check.
// Mirrors hoyo.css `.med-row`.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

enum HoyoMedTone { pink, lavender, coral }

class HoyoMedRow extends StatelessWidget {
  const HoyoMedRow({
    required this.name,
    required this.meta,
    super.key,
    this.tone = HoyoMedTone.pink,
    this.icon = Icons.medication,
    this.statusIcon = Icons.check,
    this.completed = true,
    this.onTap,
  });

  final String name;
  final String meta;
  final HoyoMedTone tone;
  final IconData icon;
  final IconData statusIcon;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (gradient, fg) = _resolveTone();
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HanaColors.surfaceContainerLowestOf(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: HanaShadowsV2.medRow,
        border: Border.all(
          color: HanaColorsV2.goldLight.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          // Pill icon disc
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HanaColorsV2.goldLight.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: HanaTypography.titleSm.copyWith(
                    color: HanaColors.onSurfaceOf(context),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: HanaTypography.labelMd.copyWith(
                    color: HanaColors.onSurfaceVariantOf(context),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Check disc
          if (completed)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: HanaGradientsV2.pillIconLavender,
                shape: BoxShape.circle,
                border: Border.all(
                  color: HanaColorsV2.goldLight.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                statusIcon,
                size: 16,
                color: HanaColors.secondaryOf(context),
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: body,
    );
  }

  (Gradient, Color) _resolveTone() {
    switch (tone) {
      case HoyoMedTone.pink:
        return (HanaGradientsV2.pillIconPink, const Color(0xFF864E5A));
      case HoyoMedTone.lavender:
        return (HanaGradientsV2.pillIconLavender, const Color(0xFF745475));
      case HoyoMedTone.coral:
        return (HanaGradientsV2.pillIconCoral, const Color(0xFFAC332A));
    }
  }
}
