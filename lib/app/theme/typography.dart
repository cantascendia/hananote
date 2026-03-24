import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Provides HanaNote typography presets.
abstract final class HanaTypography {
  /// Builds the app text theme.
  static TextTheme textTheme() {
    const foreground = ColorTokens.onSurface;

    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: foreground,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: foreground,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    );
  }
}
