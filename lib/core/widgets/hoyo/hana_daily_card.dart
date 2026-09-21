// HoYo · 每日花笺 signature card (the retention hook).
// Mirrors hoyo.css `.hana-daily` + the shape of the chat-confirmed
// design: warm twin radials, gold corner ticks, gold seal, bilingual
// flower name, italic verse, dashed footer with progress + share.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_gradients_v2.dart';
import 'package:hananote/app/theme/hana_shadows_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/data/flower_almanac.dart';
import 'package:hananote/core/widgets/hoyo/gold_text.dart';

class HanaDailyCard extends StatelessWidget {
  const HanaDailyCard({
    required this.day,
    required this.flower,
    required this.collected,
    required this.totalDays,
    required this.signatureChar,
    super.key,
    this.onShare,
  });

  final int day;
  final Flower flower;
  final int collected;
  final int totalDays;
  final String signatureChar;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final name = flower.localizedName(locale);
    final verse = flower.localizedVerse(locale);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: HanaGradientsV2.dailyPaper,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: HanaColorsV2.goldLight.withValues(alpha: 0.35),
        ),
        boxShadow: HanaShadowsV2.dailyCard,
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Stack(
        children: [
          // Warm radial wash (top-left + bottom-right).
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 0.9,
                    colors: [
                      HanaColorsV2.champagneSoft.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.55],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomRight,
                    radius: 0.9,
                    colors: [
                      const Color(0xFFFFE8EE).withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.6],
                  ),
                ),
              ),
            ),
          ),
          // Corner ticks (4 gold L-corners).
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _CornersPainter()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day-N row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'DAY $day · 第 $day 张花笺'.toUpperCase(),
                      style: HanaTypography.eyebrow.copyWith(
                        color: HanaColorsV2.goldDeep,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.54,
                      ),
                    ),
                  ),
                  // Gold seal — rotates slightly.
                  Transform.rotate(
                    angle: -8 * 3.14159 / 180,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: HanaGradientsV2.gold,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66C99A4D),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        signatureChar,
                        style: HanaTypography.labelLg.copyWith(
                          color: HanaColorsV2.plumDeep,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.11,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Flower name + Latin
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: HanaTypography.headlineMd.copyWith(
                        color: HanaColors.primaryOf(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GoldText(
                    flower.latin,
                    style: HanaTypography.labelMd.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.56,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Verse
              Text(
                verse,
                style: HanaTypography.bodyMd.copyWith(
                  color: HanaColors.onSurfaceOf(context),
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.56,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              // Dashed divider
              Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: HanaColorsV2.goldLight.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              // Footer: progress + share
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: HanaTypography.labelSm.copyWith(
                          color: HanaColorsV2.goldDeep,
                          letterSpacing: 1.32,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          const TextSpan(text: '已收集 '),
                          TextSpan(
                            text: '$collected',
                            style: TextStyle(
                              color: HanaColors.primaryOf(context),
                            ),
                          ),
                          TextSpan(text: ' / $totalDays'),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: HanaGradientsV2.gold,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4DC99A4D),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.share,
                        size: 14,
                        color: HanaColorsV2.plumDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HanaColorsV2.goldLight.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const inset = 8.0;
    const len = 22.0;
    canvas
      // top-left
      ..drawLine(
        const Offset(inset, inset),
        const Offset(inset + len, inset),
        paint,
      )
      ..drawLine(
        const Offset(inset, inset),
        const Offset(inset, inset + len),
        paint,
      )
      // top-right
      ..drawLine(
        Offset(size.width - inset - len, inset),
        Offset(size.width - inset, inset),
        paint,
      )
      ..drawLine(
        Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + len),
        paint,
      )
      // bottom-left
      ..drawLine(
        Offset(inset, size.height - inset),
        Offset(inset + len, size.height - inset),
        paint,
      )
      ..drawLine(
        Offset(inset, size.height - inset - len),
        Offset(inset, size.height - inset),
        paint,
      )
      // bottom-right
      ..drawLine(
        Offset(size.width - inset - len, size.height - inset),
        Offset(size.width - inset, size.height - inset),
        paint,
      )
      ..drawLine(
        Offset(size.width - inset, size.height - inset - len),
        Offset(size.width - inset, size.height - inset),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _CornersPainter old) => false;
}
