// Release prep note: Theme tokens are internal design-system plumbing, so
// adding dartdoc to every public constant would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:hananote/app/theme/hana_colors.dart';

class HanaGradients {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB7C5), Color(0xFFFCD3FB)],
  );

  static const countdownGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB7C5), Color(0xFFFCD3FB)],
  );

  static const takeDoseButtonGradient = LinearGradient(
    colors: [Color(0xFFFFB7C5), Color(0xFFC8A2C8)],
  );

  // -- Dark mode variants --

  static const countdownGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B1D2F), Color(0xFF432645)],
  );

  static const takeDoseButtonGradientDark = LinearGradient(
    colors: [Color(0xFF76344A), Color(0xFF5B3D5D)],
  );

  /// Returns the countdown gradient for the current theme.
  static LinearGradient countdownOf(BuildContext c) =>
      HanaColors.isDark(c) ? countdownGradientDark : countdownGradient;

  /// Returns the take-dose button gradient for the current theme.
  static LinearGradient takeDoseOf(BuildContext c) => HanaColors.isDark(c)
      ? takeDoseButtonGradientDark
      : takeDoseButtonGradient;
}
