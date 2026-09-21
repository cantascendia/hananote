// HoYo · Gold-text shader.
// Wraps any [Text] widget with a champagne→gold→deep-gold vertical
// ShaderMask. Used on display numerals (countdown, E2 value,
// Day-N labels, milestone titles).
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_gradients_v2.dart';

class GoldText extends StatelessWidget {
  const GoldText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? HanaGradientsV2.goldText;
    return ShaderMask(
      shaderCallback: (bounds) => g.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
