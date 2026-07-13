import 'package:flutter/material.dart';

// M3 Color Tokens — Light scheme, white bg, black text primary
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF1A1A1A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE5E5E5);
  static const Color onPrimaryContainer = Color(0xFF1A1A1A);

  // ── Secondary ────────────────────────────────────────────
  static const Color secondary = Color(0xFF4A4A4A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF0F0F0);
  static const Color onSecondaryContainer = Color(0xFF2C2C2C);

  // ── Tertiary ─────────────────────────────────────────────
  static const Color tertiary = Color(0xFF6B6B6B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF5F5F5);
  static const Color onTertiaryContainer = Color(0xFF3A3A3A);

  // ── Error ────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // ── Background ───────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);

  // ── Surface ──────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurfaceVariant = Color(0xFF4A4A4A);
  static const Color surfaceTint = Color(0xFF1A1A1A);

  // ── Outline ──────────────────────────────────────────────
  static const Color outline = Color(0xFF767676);
  static const Color outlineVariant = Color(0xFFD4D4D4);

  // ── Inverse ──────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFF1A1A1A);
  static const Color onInverseSurface = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFFE5E5E5);

  // ── Shadow & Scrim ───────────────────────────────────────
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── ColorScheme helper ───────────────────────────────────
  static ColorScheme get colorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    scrim: scrim,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: inversePrimary,
  );
}
