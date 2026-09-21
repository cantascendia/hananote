// HanaNote v2 (HoYo-influenced layer) — additive shadow / glow tokens.
// Diffuse warm shadows tinted with primary so they read as sunlight,
// plus glow shadows for hero cards and FABs on dark hero panels.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class HanaShadowsV2 {
  /// Resting card on cream — diffuse warm shadow.
  static const cardElevated = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A864E5A), // rgba(134,78,90,.10)
      blurRadius: 36,
      offset: Offset(0, 14),
    ),
  ];

  /// Hover lift on cards.
  static const cardHover = <BoxShadow>[
    BoxShadow(
      color: Color(0x14864E5A),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  /// Gold glow — for FABs / pills on plum hero.
  static const glowGold = <BoxShadow>[
    BoxShadow(
      color: Color(0x66E8C887), // rgba(232,200,135,.4)
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x2EC99A4D), // rgba(201,154,77,.18)
      blurRadius: 36,
      offset: Offset(0, 12),
    ),
  ];

  /// Sakura glow — for petal-themed FABs and chips.
  static const glowSakura = <BoxShadow>[
    BoxShadow(
      color: Color(0x80FFB7C5), // rgba(255,183,197,.5)
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x38FF8CAA), // rgba(255,140,170,.22)
      blurRadius: 36,
      offset: Offset(0, 12),
    ),
  ];

  /// Plum hero card — deep shadow with subtle pearl inner highlight.
  static const glowPlum = <BoxShadow>[
    BoxShadow(
      color: Color(0x522A1820), // rgba(42,24,32,.32)
      blurRadius: 48,
      offset: Offset(0, 18),
    ),
  ];

  /// CTA pill (primary, sakura→lavender).
  static const fab = <BoxShadow>[
    BoxShadow(
      color: Color(0x52C892B0), // rgba(200,146,176,.32)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Daily 花笺 card — gentle warm with subtle pearl highlight.
  static const dailyCard = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F864E5A),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];

  /// Achievement badge resting state.
  static const badge = <BoxShadow>[
    BoxShadow(
      color: Color(0x26C99A4D), // rgba(201,154,77,.15)
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Med-row card resting.
  static const medRow = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D864E5A), // rgba(134,78,90,.05)
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  /// Glass nav bar (top) — bottom-edge fade.
  static const navBar = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F864E5A),
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];
}
