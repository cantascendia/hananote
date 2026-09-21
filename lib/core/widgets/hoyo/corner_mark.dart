// HoYo · 4-point sparkle decoration (gold-light glyph).
// Mirrors the `--sparkle-svg` data URI from hoyo.css. Used as
// corner-mark on cards (`.hoyo-card.corner-mark::after`).
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';

class CornerMark extends StatelessWidget {
  const CornerMark({super.key, this.size = 14, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SparklePainter(color ?? HanaColorsV2.goldLight),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx, 0)
      // 4-point star using sakura-petal approximation, tracing the
      // SVG used in hoyo.css.
      ..lineTo(cx + size.width * 0.06, cy - size.height * 0.06)
      ..lineTo(size.width, cy)
      ..lineTo(cx + size.width * 0.06, cy + size.height * 0.06)
      ..lineTo(cx, size.height)
      ..lineTo(cx - size.width * 0.06, cy + size.height * 0.06)
      ..lineTo(0, cy)
      ..lineTo(cx - size.width * 0.06, cy - size.height * 0.06)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.color != color;
}
