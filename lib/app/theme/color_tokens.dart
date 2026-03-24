import 'package:flutter/material.dart';

/// Defines HanaNote's core color tokens.
abstract final class ColorTokens {
  /// Primary sakura pink for brand surfaces and actions.
  static const Color primary = Color(0xFFF8A4C8);

  /// Secondary lavender used for accent states.
  static const Color secondary = Color(0xFFB8A4F8);

  /// Default application background.
  static const Color background = Color(0xFFFFF8FB);

  /// Elevated card background for privacy-friendly soft contrast.
  static const Color surface = Color(0xFFFFF1F7);

  /// Main foreground color for readable text.
  static const Color onSurface = Color(0xFF36233A);

  /// Subtle divider and border color.
  static const Color outline = Color(0xFFEBC9D9);

  /// Scrim used for privacy overlay when the app is inactive.
  static const Color privacyOverlay = Color(0xFFF5D8E5);
}
