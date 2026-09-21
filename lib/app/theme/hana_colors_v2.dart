// HanaNote v2 (HoYo-influenced layer) — additive color tokens.
// Layered on top of HanaColors; references "信纸的克制 × 卡牌的精致" upgrade
// from the design bundle (gold edges, deep-jewel hero panels, refined glass).
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';

/// HoYo / 数码纸笺 v2 — gold + plum + champagne + pearl + star tokens.
///
/// Use `HanaColorsV2.xxxOf(context)` to participate in dark-mode dispatch,
/// matching the existing `HanaColors.xxxOf` pattern (DEC-061).
class HanaColorsV2 {
  // ── Brand accents — 烫金 (gold) for hairline borders, key numerals,
  //    milestone seals; 星砂 (champagne) for star/sparkle decorations.
  static const Color gold = Color(0xFFC99A4D);
  static const Color goldLight = Color(0xFFE8C887);
  static const Color goldDeep = Color(0xFF8E6A2B);
  static const Color champagne = Color(0xFFF4E5C5);
  static const Color champagneSoft = Color(0xFFFBF1DC);
  static const Color pearl = Color(0xFFFBF6EE);

  // ── Deep jewel tones — used ONLY on hero / feature surfaces (today
  //    hero, milestone cards, splash). Never on body / list cards.
  static const Color plumDeep = Color(0xFF2A1820);
  static const Color plum = Color(0xFF3B2230);
  static const Color plumSoft = Color(0xFF5A3344);
  static const Color nightSakura = Color(0xFF1F141A);

  // ── Star decoration colors (for HoYo-style sparkle SVG / particles).
  static const Color starBright = Color(0xFFFFF6D9);
  static const Color starMid = Color(0xFFE8C887);
  static const Color starDim = Color(0x59E8C887); // rgba(232,200,135,.35)

  // ── Hairline overlay alphas (for HoYo card edge treatment).
  // ARGB hex; combine with the gold base via Color.withValues if needed.
  static const Color hairlineGold = Color(0x8CE8C887); // .55 alpha
  static const Color hairlineGoldSoft = Color(0x40E8C887); // .25 alpha
  static const Color hairlinePearl = Color(0x2EFFFFFF); // .18 alpha
  static const Color hairlinePlum = Color(0x1A3B2230); // .10 alpha

  // ── Status: cool success green (sole cool color in the system).
  static const Color statusGreen = Color(0xFF34D399);
  static const Color statusGreenSoft = Color(0xFF88E8B8);

  // ── Dark variants — gold sinks to gold-deep, plum stays the same
  //    (already deep), pearl/champagne → plum tones.
  static const Color goldDark = goldDeep;
  static const Color goldLightDark = Color(0xFFB8924A);
  static const Color pearlDark = Color(0xFF2B2420);
  static const Color champagneSoftDark = Color(0xFF362E29);

  /// Returns true when the current theme uses dark brightness.
  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  // ── Context-aware accessors. Match HanaColors.xxxOf naming.
  static Color goldOf(BuildContext c) => _isDark(c) ? goldDark : gold;
  static Color goldLightOf(BuildContext c) =>
      _isDark(c) ? goldLightDark : goldLight;
  static Color goldDeepOf(BuildContext c) => goldDeep;
  static Color champagneOf(BuildContext c) =>
      _isDark(c) ? champagneSoftDark : champagne;
  static Color champagneSoftOf(BuildContext c) =>
      _isDark(c) ? champagneSoftDark : champagneSoft;
  static Color pearlOf(BuildContext c) => _isDark(c) ? pearlDark : pearl;

  // Plum tones don't shift with brightness — they're already night-sakura.
  static Color plumOf(BuildContext c) => plum;
  static Color plumDeepOf(BuildContext c) => plumDeep;
  static Color plumSoftOf(BuildContext c) => plumSoft;
  static Color nightSakuraOf(BuildContext c) => nightSakura;

  // Star decorations: light theme uses bright; dark uses dimmed gold.
  static Color starBrightOf(BuildContext c) =>
      _isDark(c) ? goldLightDark : starBright;
  static Color starMidOf(BuildContext c) => starMid;

  // Hairline alphas: same in both modes (alpha-blended over surface).
  static Color hairlineGoldOf(BuildContext c) => hairlineGold;
  static Color hairlineGoldSoftOf(BuildContext c) => hairlineGoldSoft;

  /// Surface used as text/icon foreground on plum hero cards.
  /// Always pearl regardless of brightness (cards are always dark).
  static Color heroForegroundOf(BuildContext c) => pearl;

  /// Subtle foreground on plum hero (e.g. eyebrow underlines, captions).
  static Color heroForegroundDimOf(BuildContext c) =>
      pearl.withValues(alpha: 0.65);

  /// On hero, gold body text (numerals, brand prefix).
  static Color heroGoldOf(BuildContext c) => goldLight;

  /// Sub-pill glass background on plum hero (rgba(255,246,238,.08)).
  static Color heroGlassFillOf(BuildContext c) => pearl.withValues(alpha: 0.08);

  /// Sub-pill glass border on plum hero (rgba(232,200,135,.28)).
  static Color heroGlassBorderOf(BuildContext c) =>
      goldLight.withValues(alpha: 0.28);

  /// Compose with [HanaColors.surfaceContainerLowestOf] for HoyoCard chassis.
  /// Returns the resting card background (always lowest tonal step).
  static Color cardChassisOf(BuildContext c) =>
      HanaColors.surfaceContainerLowestOf(c);
}
