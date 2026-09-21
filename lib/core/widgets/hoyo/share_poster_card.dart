// HoYo · Share poster card (9:16) — HRT 第 N 天 commemorative card.
// Renders inside a RepaintBoundary so callers can capture as PNG via
// `RenderRepaintBoundary.toImage`.
//
// Layout: plum twilight hero + gold seal + "HRT 第 N 天" gold-text +
// 花押 signature + QR placeholder + 花笺 wordmark footer.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/conic_avatar_ring.dart';
import 'package:hananote/core/widgets/hoyo/gold_text.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_stars.dart';

class SharePosterCard extends StatelessWidget {
  const SharePosterCard({
    required this.day,
    required this.signatureChar,
    required this.flowerName,
    required this.flowerLatin,
    required this.startDate,
    super.key,
    this.aspectRatio = 9 / 16,
  });

  final int day;
  final String signatureChar;
  final String flowerName;
  final String flowerLatin;
  final String startDate;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: HanaGradientsV2.heroNight,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // Sakura halo
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  gradient: HanaGradientsV2.petalHalo,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Stars
            Positioned.fill(
              child: HoyoStars(
                density: 1.5,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: brand + eyebrow
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_florist,
                            color: HanaColorsV2.goldLight,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '花笺 HanaNote',
                            style: HanaTypography.titleMd.copyWith(
                              color: HanaColorsV2.champagneSoft,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'COMMEMORATIVE CARD'.toUpperCase(),
                        style: HanaTypography.eyebrow.copyWith(
                          color: HanaColorsV2.pearl.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  // Middle: day count + flower
                  Column(
                    children: [
                      ConicAvatarRing(label: signatureChar, size: 72),
                      const SizedBox(height: 24),
                      Text(
                        'HRT',
                        style: HanaTypography.eyebrow.copyWith(
                          color: HanaColorsV2.goldLight,
                          letterSpacing: 4,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GoldText(
                        '第 $day 天',
                        style: HanaTypography.displayLg.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 56,
                          letterSpacing: -1.12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: HanaColorsV2.pearl.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color:
                                HanaColorsV2.goldLight.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '$flowerName · $flowerLatin',
                          style: HanaTypography.labelMd.copyWith(
                            color: HanaColorsV2.pearl,
                            letterSpacing: 0.66,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom: signature + start date + small QR placeholder
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: HanaColorsV2.pearl.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: HanaColorsV2.goldLight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.qr_code_2,
                          size: 44,
                          color: HanaColorsV2.plumDeep,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$startDate · 花笺持有者',
                        style: HanaTypography.labelSm.copyWith(
                          color: HanaColorsV2.pearl.withValues(alpha: 0.7),
                          letterSpacing: 1.32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
