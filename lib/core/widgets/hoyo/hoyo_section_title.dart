// HoYo · Section title with vertical gold tick + optional small subtitle.
// Mirrors hoyo.css `.hoyo-section-title`.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

class HoyoSectionTitle extends StatelessWidget {
  const HoyoSectionTitle({
    required this.title,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final fg = HanaColors.onSurfaceOf(context);
    final fgVariant = HanaColors.onSurfaceVariantOf(context);
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -14,
            top: 6,
            bottom: 6,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HanaColorsV2.goldLight,
                    HanaColors.primaryOf(context),
                  ],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: HanaTypography.titleLg.copyWith(color: fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: HanaTypography.labelMd
                        .copyWith(color: fgVariant, letterSpacing: 0.56),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
