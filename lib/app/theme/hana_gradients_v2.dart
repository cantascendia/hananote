// HanaNote v2 (HoYo-influenced layer) — additive gradient tokens.
// Pairs darker plum cores with sakura halos so cards read as
// "warm twilight glass" (per design bundle hoyo.css recipes).
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors_v2.dart';

/// HoYo / 数码纸笺 v2 — hero / gold / petal gradients.
class HanaGradientsV2 {
  // ── Hero gradient system (HoYo-style two-step) ─────────────────
  // Each gradient pairs a darker plum core with a sakura halo.
  static const heroNight = RadialGradient(
    center: Alignment(-0.76, -1),
    radius: 1.4,
    colors: [
      HanaColorsV2.plumSoft,
      HanaColorsV2.plumDeep,
      HanaColorsV2.nightSakura,
    ],
    stops: [0, 0.55, 1],
  );

  static const heroDawn = RadialGradient(
    center: Alignment.topRight,
    radius: 1.2,
    colors: [
      Color(0xFFFFD7E2),
      Color(0xFFF8B5C7),
      Color(0xFFC892B0),
    ],
    stops: [0, 0.35, 1],
  );

  static const heroPearl = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      HanaColorsV2.pearl,
      Color(0xFFFFE8EE),
      Color(0xFFFCD3FB),
    ],
    stops: [0, 0.6, 1],
  );

  // ── Gold accents (for pills, seals, eyebrows) ──────────────────
  static const gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      HanaColorsV2.goldLight,
      HanaColorsV2.gold,
      HanaColorsV2.goldDeep,
    ],
    stops: [0, 0.5, 1],
  );

  /// Vertical gold gradient used as a ShaderMask on display numerals.
  static const goldText = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      HanaColorsV2.champagneSoft,
      HanaColorsV2.goldLight,
      HanaColorsV2.gold,
    ],
    stops: [0, 0.5, 1],
  );

  // ── Petal halo overlay for hero cards (transparent → sakura). ──
  static final petalHalo = RadialGradient(
    center: Alignment.topRight,
    radius: 0.9,
    colors: [
      const Color(0xFFFFB7C5).withValues(alpha: 0.45),
      const Color(0xFFFFB7C5).withValues(alpha: 0),
    ],
    stops: const [0, 0.7],
  );

  // ── Daily 花笺 paper background (warm twin radials over cream). ──
  static const dailyPaper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFCF6),
      Color(0xFFFBF6EE),
    ],
  );

  // ── Med-row pill icon discs (3 tones: pink / lavender / coral). ─
  static const pillIconPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE8EE), Color(0xFFFCD3FB)],
  );

  static const pillIconLavender = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCD3FB), Color(0xFFE2BAE1)],
  );

  static const pillIconCoral = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFDAD5), Color(0xFFFFB9B0)],
  );

  /// Achievement badge unlocked face (champagne).
  static const badgeUnlocked = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF1DC), Color(0xFFF4E5C5)],
  );

  /// Achievement badge locked face (greyscale).
  static const badgeLocked = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6C2C4), Color(0xFFA08A8C)],
  );

  // ── Conic gradient sweep for avatar ring (Profile hero). ───────
  /// Use with SweepGradient on a 84×84 disc; rotates from 220° start.
  static const avatarRing = SweepGradient(
    endAngle: 6.28318, // 2π
    colors: [
      HanaColorsV2.goldLight,
      Color(0xFFFFB7C5),
      Color(0xFFC892B0),
      HanaColorsV2.goldLight,
    ],
    stops: [0, 0.33, 0.66, 1],
  );

  /// Rotating halo behind E2 numeral on Data tab. Animated via
  /// AnimationController in `ConicHalo` widget.
  static SweepGradient conicHalo({double startAngleDeg = 0}) {
    final s = startAngleDeg * 3.14159 / 180;
    return SweepGradient(
      startAngle: s,
      endAngle: s + 6.28318,
      colors: const [
        Color(0xFFFFB7C5),
        Color(0xFFE8C887),
        Color(0xFFC892B0),
        Color(0xFFFFB7C5),
      ],
      stops: const [0, 0.33, 0.66, 1],
    );
  }
}
