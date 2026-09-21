// HanaNote v2 — typography tokens.
// Plus Jakarta Sans (display / headings / numerals — heavy 800 / -0.02em)
// Be Vietnam Pro (body / labels — generous 1.55 line-height)
// CJK fallback: 苹方-简 / Hiragino Sans GB / Source Han / system.
// On the device, system CJK is preferred; web/dev uses GoogleFonts.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'package:hananote/app/theme/hana_colors.dart';

/// Font family names. We use TextTheme + fontFamilyFallback rather than
/// embedding TTFs (keeps APK size + matches release-mode CJK system).
class HanaTypography {
  // Display family (Plus Jakarta Sans + CJK fallback chain).
  static const String displayFamily = 'PlusJakartaSans';
  // Body family (Be Vietnam Pro + CJK fallback chain).
  static const String bodyFamily = 'BeVietnamPro';

  // CJK fallback chain. On platforms missing Plus Jakarta Sans,
  // these provide passable typography for Chinese / Japanese.
  static const List<String> cjkFallback = <String>[
    'Noto Sans SC',
    'PingFang SC',
    'Hiragino Sans GB',
    'Microsoft YaHei',
    'Source Han Sans CN',
    'sans-serif',
  ];

  // ── Type scale — Material 3 inspired, tuned for HanaNote.
  // Display is non-symmetric & slightly oversized for emotional weight.

  static const TextStyle displayLg = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w800,
    fontSize: 56,
    height: 1.05,
    letterSpacing: -1.12, // -0.02em at 56px
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w800,
    fontSize: 44,
    height: 1.08,
    letterSpacing: -0.88,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.12,
    letterSpacing: -0.32,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w800,
    fontSize: 28,
    height: 1.18,
    letterSpacing: -0.28,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.22,
    letterSpacing: -0.12,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.28,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.4,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.4,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.55,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.55,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.5,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.3,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.3,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    height: 1.3,
  );

  /// Eyebrow — uppercase, tracking-widest. Used above headlines on
  /// HoYo cards. Spacing 0.22em ≈ 2.42 at 11px.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: cjkFallback,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1.4,
    letterSpacing: 2.42,
  );

  /// Build a Material 3 [TextTheme] composed from these styles, applying
  /// the appropriate `on-surface` / `on-surface-variant` colors via
  /// `HanaColors.xxxOf` dispatch.
  static TextTheme buildTextTheme(BuildContext context) {
    final fg = HanaColors.onSurfaceOf(context);
    final fgVariant = HanaColors.onSurfaceVariantOf(context);

    return TextTheme(
      displayLarge: displayLg.copyWith(color: HanaColors.primaryOf(context)),
      displayMedium: displayMd.copyWith(color: HanaColors.primaryOf(context)),
      displaySmall: displaySm.copyWith(color: fg),
      headlineLarge: headlineLg.copyWith(color: fg),
      headlineMedium: headlineMd.copyWith(color: fg),
      headlineSmall: headlineSm.copyWith(color: fg),
      titleLarge: titleLg.copyWith(color: fg),
      titleMedium: titleMd.copyWith(color: fg),
      titleSmall: titleSm.copyWith(color: fg),
      bodyLarge: bodyLg.copyWith(color: fg),
      bodyMedium: bodyMd.copyWith(color: fgVariant),
      bodySmall: bodySm.copyWith(color: fgVariant),
      labelLarge: labelLg.copyWith(color: fg),
      labelMedium: labelMd.copyWith(color: fgVariant),
      labelSmall: labelSm.copyWith(color: fgVariant),
    );
  }
}
