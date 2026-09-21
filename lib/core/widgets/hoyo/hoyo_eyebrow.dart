// HoYo · Eyebrow — uppercase tracking-widest label with gold prefix dash.
// Used above headlines on hero / card surfaces. Two tones:
//   - light tone (gold-light) for plum hero panels
//   - dark tone (gold-deep) for cream card surfaces
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';

enum HoyoEyebrowTone { light, dark }

class HoyoEyebrow extends StatelessWidget {
  const HoyoEyebrow(
    this.label, {
    super.key,
    this.tone = HoyoEyebrowTone.dark,
    this.center = false,
  });

  final String label;
  final HoyoEyebrowTone tone;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final color = tone == HoyoEyebrowTone.light
        ? HanaColorsV2.goldLight
        : HanaColorsV2.goldDeep;
    final dashGradient = LinearGradient(
      colors: [Colors.transparent, color],
    );
    final children = <Widget>[
      Container(
        width: 18,
        height: 1,
        decoration: BoxDecoration(gradient: dashGradient),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          label,
          style: HanaTypography.eyebrow.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
    return Row(
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: children,
    );
  }
}
