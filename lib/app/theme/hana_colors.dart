// Release prep note: Theme tokens are internal design-system plumbing, so
// adding dartdoc to every public constant would add noise without value.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class HanaColors {
  // Map color hex to Color objects
  static const Color background = Color(0xFFFFF8F1);
  static const Color surface = Color(0xFFFFF8F1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9F3EB);
  static const Color surfaceContainer = Color(0xFFF4EDE5);
  static const Color surfaceContainerHigh = Color(0xFFEEE7DF);
  static const Color surfaceContainerHighest = Color(0xFFE8E1DA);

  static const Color primary = Color(0xFF864E5A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFFB7C5);
  static const Color onPrimaryContainer = Color(0xFF7B4551);

  static const Color secondary = Color(0xFF745475);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFCD3FB);
  static const Color onSecondaryContainer = Color(0xFF78587A);

  static const Color tertiary = Color(0xFFAC332A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFB9B0);
  static const Color onTertiaryContainer = Color(0xFF9F2922);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color onSurface = Color(0xFF1E1B17);
  static const Color onSurfaceVariant = Color(0xFF514345);
  static const Color outline = Color(0xFF837375);
  static const Color outlineVariant = Color(0xFFD6C2C4);

  static const Color inverseSurface = Color(0xFF33302B);
  static const Color inverseOnSurface = Color(0xFFF7F0E8);
  static const Color inversePrimary = Color(0xFFFBB3C1);

  static const Color surfaceTint = Color(0xFF864E5A);
  static const Color surfaceBright = Color(0xFFFFF8F1);
  static const Color surfaceDim = Color(0xFFDFD9D1);
  static const Color surfaceVariant = Color(0xFFE8E1DA);

  static const Color primaryFixed = Color(0xFFFFD9DF);
  static const Color primaryFixedDim = Color(0xFFFBB3C1);
  static const Color onPrimaryFixed = Color(0xFF360C19);
  static const Color onPrimaryFixedVariant = Color(0xFF6B3743);

  static const Color secondaryFixed = Color(0xFFFFD6FE);
  static const Color secondaryFixedDim = Color(0xFFE2BAE1);
  static const Color onSecondaryFixed = Color(0xFF2B112F);
  static const Color onSecondaryFixedVariant = Color(0xFF5A3C5D);

  static const Color statusGreen = Color(0xFF34D399);

  static const Color tertiaryFixed = Color(0xFFFFDAD5);
  static const Color tertiaryFixedDim = Color(0xFFFFB4AA);
  static const Color onTertiaryFixed = Color(0xFF410001);
  static const Color onTertiaryFixedVariant = Color(0xFF8B1A16);

  /// Returns true when the current theme uses dark brightness.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // -- Context-aware color accessors for dark mode support --

  static Color backgroundOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.background : background;
  static Color surfaceOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surface : surface;
  static Color surfaceContainerLowestOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceContainerLowest : surfaceContainerLowest;
  static Color surfaceContainerLowOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceContainerLow : surfaceContainerLow;
  static Color surfaceContainerOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceContainer : surfaceContainer;
  static Color surfaceContainerHighOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceContainerHigh : surfaceContainerHigh;
  static Color surfaceContainerHighestOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceContainerHighest : surfaceContainerHighest;
  static Color primaryOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.primary : primary;
  static Color onPrimaryOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.onPrimary : onPrimary;
  static Color primaryContainerOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.primaryContainer : primaryContainer;
  static Color onPrimaryContainerOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.onPrimaryContainer : onPrimaryContainer;
  static Color onSurfaceOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.onSurface : onSurface;
  static Color onSurfaceVariantOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.onSurfaceVariant : onSurfaceVariant;
  static Color outlineOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.outline : outline;
  static Color outlineVariantOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.outlineVariant : outlineVariant;
  static Color secondaryOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.secondary : secondary;
  static Color secondaryContainerOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.secondaryContainer : secondaryContainer;
  static Color tertiaryOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.tertiary : tertiary;
  static Color tertiaryContainerOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.tertiaryContainer : tertiaryContainer;
  static Color errorOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.error : error;
  static Color inverseSurfaceOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.inverseSurface : inverseSurface;
  static Color inverseOnSurfaceOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.inverseOnSurface : inverseOnSurface;
  static Color surfaceDimOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.surfaceDim : surfaceDim;
  static Color primaryFixedOf(BuildContext c) =>
      isDark(c) ? HanaColorsDark.primaryFixed : primaryFixed;
}

/// Warm dark palette for HanaNote (no pure black/white per DESIGN.md).
abstract final class HanaColorsDark {
  static const Color primary = Color(0xFFFBB3C1);
  static const Color onPrimary = Color(0xFF5B1D2F);
  static const Color primaryContainer = Color(0xFF76344A);
  static const Color onPrimaryContainer = Color(0xFFFFD9E0);

  static const Color secondary = Color(0xFFE4B8E8);
  static const Color onSecondary = Color(0xFF432645);
  static const Color secondaryContainer = Color(0xFF5B3D5D);
  static const Color onSecondaryContainer = Color(0xFFFCD3FB);

  static const Color tertiary = Color(0xFFFFB9B0);
  static const Color onTertiary = Color(0xFF5C1410);
  static const Color tertiaryContainer = Color(0xFF7D2C27);
  static const Color onTertiaryContainer = Color(0xFFFFDAD6);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);

  static const Color background = Color(0xFF1A1512);
  static const Color onBackground = Color(0xFFF7F0E8);
  static const Color surface = Color(0xFF1A1512);
  static const Color onSurface = Color(0xFFF7F0E8);
  static const Color onSurfaceVariant = Color(0xFFD6C2C4);

  static const Color surfaceDim = Color(0xFF171310);
  static const Color surfaceContainerLowest = Color(0xFF110E0C);
  static const Color surfaceContainerLow = Color(0xFF1F1A16);
  static const Color surfaceContainer = Color(0xFF2B2420);
  static const Color surfaceContainerHigh = Color(0xFF362E29);
  static const Color surfaceContainerHighest = Color(0xFF413833);

  static const Color outline = Color(0xFFA08A8C);
  static const Color outlineVariant = Color(0xFF514345);

  static const Color inverseSurface = Color(0xFFF7F0E8);
  static const Color inverseOnSurface = Color(0xFF33302B);
  static const Color inversePrimary = Color(0xFF864E5A);

  static const Color statusGreen = Color(0xFF34D399);

  static const Color primaryFixed = Color(0xFFFFD9DF);
}
