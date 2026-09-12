// Release prep note: Theme tokens are internal design-system plumbing, so
// adding dartdoc to every public constant would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// HanaTokens — single-API access for HanaNote v2 design tokens.
///
/// Source of truth: `docs/design/design-system/v2/tokens.md`.
///
/// Usage:
/// ```dart
/// final bg = HanaTokens.background(context);
/// final pad = HanaTokens.spacing.md; // 16.0
/// final radius = HanaTokens.radius.card; // BorderRadius.circular(4)
/// final dur = HanaTokens.motion.standard; // Duration(milliseconds: 240)
/// ```
///
/// All color getters are context-aware and return the correct light / dark
/// value based on `Theme.of(context).brightness`. Spacing / radius / motion
/// are static (no context dependency).
class HanaTokens {
  const HanaTokens._();

  // ---------------------------------------------------------------------
  // Colors — Light + Dark (see tokens.md §1)
  // ---------------------------------------------------------------------

  // Light palette.
  static const Color _backgroundLight = Color(0xFFF4F1EA); // 月白
  static const Color _surfaceLowestLight = Color(0xFFFBF8F2); // 雪宣
  static const Color _surfaceLowLight = Color(0xFFF4F1EA); // 月白
  static const Color _surfaceHighLight = Color(0xFFEAE6DD); // 米灰
  static const Color _surfaceHighestLight = Color(0xFFDCD7CC); // 砚灰
  static const Color _inkLight = Color(0xFF1C1A18); // 墨色
  static const Color _inkSecondaryLight = Color(0xFF5E5A52); // 淡墨
  static const Color _outlineLight = Color(0xFFA39E92); // 烟灰
  static const Color _primaryLight = Color(0xFF1F3A5F); // 黛蓝
  static const Color _onPrimaryLight = Color(0xFFFBF8F2);
  static const Color _accentMutedLight = Color(0xFFE5E9EE); // 远黛
  static const Color _errorLight = Color(0xFF9B2A2A); // 朱砂
  static const Color _successLight = Color(0xFF5C6B4F); // 苔色
  static const Color _warningLight = Color(0xFFA6814C); // 香灰

  // Dark palette.
  static const Color _backgroundDark = Color(0xFF1C1A18);
  static const Color _surfaceLowestDark = Color(0xFF252320);
  static const Color _surfaceLowDark = Color(0xFF1C1A18);
  static const Color _surfaceHighDark = Color(0xFF2D2A26);
  static const Color _surfaceHighestDark = Color(0xFF363330);
  static const Color _inkDark = Color(0xFFE8E4DB);
  static const Color _inkSecondaryDark = Color(0xFFA39E92);
  static const Color _outlineDark = Color(0xFFA39E92);
  static const Color _primaryDark = Color(0xFF7A9CC2);
  static const Color _onPrimaryDark = Color(0xFF1C1A18);
  static const Color _accentMutedDark = Color(0xFF2A3340);
  static const Color _errorDark = Color(0xFFD67878);
  static const Color _successDark = Color(0xFF7E8F70);
  static const Color _warningDark = Color(0xFFC5A06A);

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  // -- Public color accessors --
  static Color background(BuildContext c) =>
      _isDark(c) ? _backgroundDark : _backgroundLight;
  static Color surfaceContainerLowest(BuildContext c) =>
      _isDark(c) ? _surfaceLowestDark : _surfaceLowestLight;
  static Color surfaceContainerLow(BuildContext c) =>
      _isDark(c) ? _surfaceLowDark : _surfaceLowLight;
  static Color surfaceContainerHigh(BuildContext c) =>
      _isDark(c) ? _surfaceHighDark : _surfaceHighLight;
  static Color surfaceContainerHighest(BuildContext c) =>
      _isDark(c) ? _surfaceHighestDark : _surfaceHighestLight;
  static Color ink(BuildContext c) => _isDark(c) ? _inkDark : _inkLight;
  static Color inkSecondary(BuildContext c) =>
      _isDark(c) ? _inkSecondaryDark : _inkSecondaryLight;
  static Color outline(BuildContext c) =>
      _isDark(c) ? _outlineDark : _outlineLight;
  static Color primary(BuildContext c) =>
      _isDark(c) ? _primaryDark : _primaryLight;
  static Color onPrimary(BuildContext c) =>
      _isDark(c) ? _onPrimaryDark : _onPrimaryLight;
  static Color accentMuted(BuildContext c) =>
      _isDark(c) ? _accentMutedDark : _accentMutedLight;
  static Color error(BuildContext c) => _isDark(c) ? _errorDark : _errorLight;
  static Color success(BuildContext c) =>
      _isDark(c) ? _successDark : _successLight;
  static Color warning(BuildContext c) =>
      _isDark(c) ? _warningDark : _warningLight;

  // ---------------------------------------------------------------------
  // Spacing / Radius / Motion (no context dependency)
  // ---------------------------------------------------------------------

  static const _Spacing spacing = _Spacing();
  static const _Radius radius = _Radius();
  static const _Motion motion = _Motion();
  static const _Typography typography = _Typography();

  // ---------------------------------------------------------------------
  // ColorScheme builders (hand-rolled — no fromSeed; 黛蓝 is scarce)
  // ---------------------------------------------------------------------

  static ColorScheme lightScheme() => const ColorScheme(
        brightness: Brightness.light,
        primary: _primaryLight,
        onPrimary: _onPrimaryLight,
        primaryContainer: _accentMutedLight,
        onPrimaryContainer: _primaryLight,
        secondary: _inkSecondaryLight,
        onSecondary: _backgroundLight,
        secondaryContainer: _surfaceHighLight,
        onSecondaryContainer: _inkLight,
        tertiary: _warningLight,
        onTertiary: _backgroundLight,
        error: _errorLight,
        onError: _onPrimaryLight,
        errorContainer: Color(0xFFF4DCDC),
        onErrorContainer: _errorLight,
        surface: _backgroundLight,
        onSurface: _inkLight,
        surfaceContainerLowest: _surfaceLowestLight,
        surfaceContainerLow: _surfaceLowLight,
        surfaceContainer: _surfaceLowLight,
        surfaceContainerHigh: _surfaceHighLight,
        surfaceContainerHighest: _surfaceHighestLight,
        onSurfaceVariant: _inkSecondaryLight,
        outline: _outlineLight,
        outlineVariant: Color(0x4DA39E92), // outline @ 30%
        surfaceTint: _primaryLight,
        inverseSurface: _inkLight,
        onInverseSurface: _backgroundLight,
        inversePrimary: _primaryDark,
        scrim: Color(0x521C1A18),
        shadow: _inkLight,
      );

  static ColorScheme darkScheme() => const ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryDark,
        onPrimary: _onPrimaryDark,
        primaryContainer: _accentMutedDark,
        onPrimaryContainer: _primaryDark,
        secondary: _inkSecondaryDark,
        onSecondary: _backgroundDark,
        secondaryContainer: _surfaceHighDark,
        onSecondaryContainer: _inkDark,
        tertiary: _warningDark,
        onTertiary: _backgroundDark,
        error: _errorDark,
        onError: _onPrimaryDark,
        errorContainer: Color(0xFF3A2222),
        onErrorContainer: _errorDark,
        surface: _backgroundDark,
        onSurface: _inkDark,
        surfaceContainerLowest: _surfaceLowestDark,
        surfaceContainerLow: _surfaceLowDark,
        surfaceContainer: _surfaceLowDark,
        surfaceContainerHigh: _surfaceHighDark,
        surfaceContainerHighest: _surfaceHighestDark,
        onSurfaceVariant: _inkSecondaryDark,
        outline: _outlineDark,
        outlineVariant: Color(0x4DA39E92),
        surfaceTint: _primaryDark,
        inverseSurface: _inkDark,
        onInverseSurface: _backgroundDark,
        inversePrimary: _primaryLight,
        scrim: Color(0x52000000),
        shadow: Color(0xFF000000),
      );

  // ---------------------------------------------------------------------
  // ThemeData factories
  // ---------------------------------------------------------------------

  static ThemeData lightTheme() => _buildTheme(lightScheme());
  static ThemeData darkTheme() => _buildTheme(darkScheme());

  static ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _Typography._buildTextTheme(scheme.onSurface),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius.card),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

/// Spacing scale — 4px baseline, intentionally skipping 12 / 20 to force
/// editorial rhythm. Adjacent gaps must cross levels (no `md` next to `md`).
class _Spacing {
  const _Spacing();
  final double xs = 4;
  final double sm = 8;
  final double md = 16;
  final double lg = 32;
  final double xl = 64;
  final double xxl = 128;
}

/// Radius scale. v2 collapses v1's 16-24px to 4px-dominant editorial corners.
class _Radius {
  const _Radius();
  final BorderRadius input = const BorderRadius.all(Radius.circular(2));
  final BorderRadius photo = const BorderRadius.all(Radius.circular(2));
  final BorderRadius card = const BorderRadius.all(Radius.circular(4));
  final BorderRadius button = const BorderRadius.all(Radius.circular(6));
  final BorderRadius sheet =
      const BorderRadius.vertical(top: Radius.circular(16));
}

/// Motion durations + curves — the celebration ritual depends on these.
class _Motion {
  const _Motion();
  final Duration instant = const Duration(milliseconds: 80);
  final Duration quick = const Duration(milliseconds: 150);
  final Duration standard = const Duration(milliseconds: 240);
  final Duration deliberate = const Duration(milliseconds: 600);
  final Duration fade = const Duration(milliseconds: 1200);
  final Curve easeOut = Curves.easeOut;
  final Curve easeInOut = Curves.easeInOut;
  final Curve linear = Curves.linear;
}

/// Typography — Spectral / Inter / JetBrains Mono + CJK fallback chain.
class _Typography {
  const _Typography();

  static const List<String> serifFallback = <String>[
    'Source Han Serif SC',
    'Noto Serif JP',
    'Hiragino Mincho ProN',
    'Yu Mincho',
    'STSong',
    'serif',
  ];

  static const List<String> sansFallback = <String>[
    'Source Han Sans SC',
    'Noto Sans JP',
    'PingFang SC',
    'Hiragino Sans GB',
    'Microsoft YaHei',
    'sans-serif',
  ];

  static const List<String> monoFallback = <String>[
    'SF Mono',
    'Consolas',
    'monospace',
  ];

  TextStyle get displayXl => const TextStyle(
        fontFamily: 'Spectral',
        fontFamilyFallback: serifFallback,
        fontSize: 40,
        height: 52 / 40,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w600,
      );
  TextStyle get display => const TextStyle(
        fontFamily: 'Spectral',
        fontFamilyFallback: serifFallback,
        fontSize: 32,
        height: 42 / 32,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w600,
      );
  TextStyle get displayMd => const TextStyle(
        fontFamily: 'Spectral',
        fontFamilyFallback: serifFallback,
        fontSize: 28,
        height: 38 / 28,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w600,
      );
  TextStyle get headline => const TextStyle(
        fontFamily: 'Spectral',
        fontFamilyFallback: serifFallback,
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w400,
      );
  TextStyle get title => const TextStyle(
        fontFamily: 'Spectral',
        fontFamilyFallback: serifFallback,
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w400,
      );
  TextStyle get body => const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: sansFallback,
        fontSize: 15,
        height: 24 / 15,
        fontWeight: FontWeight.w400,
      );
  TextStyle get bodySm => const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: sansFallback,
        fontSize: 13,
        height: 20 / 13,
        fontWeight: FontWeight.w400,
      );
  TextStyle get label => const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: sansFallback,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w500,
      );
  TextStyle get mono => const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontFamilyFallback: monoFallback,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w300,
      );

  static TextTheme _buildTextTheme(Color onSurface) {
    const t = _Typography();
    return TextTheme(
      displayLarge: t.displayXl.copyWith(color: onSurface),
      displayMedium: t.display.copyWith(color: onSurface),
      displaySmall: t.displayMd.copyWith(color: onSurface),
      headlineLarge: t.headline.copyWith(color: onSurface),
      headlineMedium: t.headline.copyWith(color: onSurface),
      headlineSmall: t.title.copyWith(color: onSurface),
      titleLarge: t.title.copyWith(color: onSurface),
      titleMedium: t.title.copyWith(color: onSurface),
      titleSmall: t.bodySm.copyWith(color: onSurface),
      bodyLarge: t.body.copyWith(color: onSurface),
      bodyMedium: t.body.copyWith(color: onSurface),
      bodySmall: t.bodySm.copyWith(color: onSurface),
      labelLarge: t.label.copyWith(color: onSurface),
      labelMedium: t.label.copyWith(color: onSurface),
      labelSmall: t.label.copyWith(color: onSurface),
    );
  }
}
