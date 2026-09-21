// HoYo · Achievement badge — stamp-style 圣遗物 card.
// Mirrors hoyo.css `.hoyo-badge`.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoBadge extends StatelessWidget {
  const HoyoBadge({
    required this.icon,
    required this.label,
    required this.name,
    required this.unlocked,
    super.key,
  });

  final IconData icon;
  final String label;
  final String name;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final faded = !unlocked;
    return Opacity(
      opacity: faded ? 0.42 : 1,
      child: ColorFiltered(
        colorFilter: faded
            ? const ColorFilter.matrix([
                0.5,
                0.5,
                0.5,
                0,
                0,
                0.5,
                0.5,
                0.5,
                0,
                0,
                0.5,
                0.5,
                0.5,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ])
            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: HanaGradientsV2.badgeUnlocked,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: HanaColorsV2.goldLight.withValues(alpha: 0.55),
            ),
            boxShadow: HanaShadowsV2.badge,
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: unlocked
                      ? HanaGradientsV2.gold
                      : HanaGradientsV2.badgeLocked,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 20,
                  color: HanaColorsV2.plumDeep,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: HanaTypography.labelSm.copyWith(
                  color: HanaColorsV2.goldDeep,
                  letterSpacing: 1.26,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HanaTypography.labelMd.copyWith(
                  color: const Color(0xFF864E5A),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
