import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'typography.dart';

/// Builds the shared application theme.
abstract final class AppTheme {
  /// Creates the light theme used across HanaNote.
  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: ColorTokens.primary,
          primary: ColorTokens.primary,
          secondary: ColorTokens.secondary,
          surface: ColorTokens.surface,
          brightness: Brightness.light,
        ).copyWith(
          surface: ColorTokens.surface,
          onSurface: ColorTokens.onSurface,
          outline: ColorTokens.outline,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorTokens.background,
      textTheme: HanaTypography.textTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ColorTokens.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ColorTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: ColorTokens.outline),
        ),
      ),
    );
  }
}
