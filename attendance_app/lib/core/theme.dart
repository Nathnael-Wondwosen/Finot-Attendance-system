import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/theme_provider.dart';

/// =======================================================
/// TONAL PALETTE (LIKE ANDROID SETTINGS)
/// =======================================================
class TonalPalette {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;

  TonalPalette({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
  });

  factory TonalPalette.from(Color seed, double tone, Brightness brightness) {
    final base = AppTheme.applyTone(seed, tone);

    return TonalPalette(
      primary: base,
      onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
      surface:
          brightness == Brightness.dark
              ? AppTheme.applyTone(base, 0.28)
              : AppTheme.applyTone(base, 1.85),
      surfaceVariant:
          brightness == Brightness.dark
              ? AppTheme.applyTone(base, 0.20)
              : AppTheme.applyTone(base, 1.55),
      outline: AppTheme.applyTone(base, 0.75),
    );
  }
}

class AppTheme {
  /// =======================================================
  /// BASE COLORS
  /// =======================================================
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFB300);
  static const Color infoColor = Color(0xFF1976D2);

  /// =======================================================
  /// TONE ADJUSTMENT (KEY PART – MATCHES SAMPLE UI)
  /// =======================================================
  /// tone:
  ///   0.6  → very light
  ///   1.0  → natural
  ///   1.2+ → darker / richer
  static Color applyTone(Color color, double tone) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness * tone).clamp(0.12, 0.92);
    return hsl.withLightness(lightness).toColor();
  }

  /// =======================================================
  /// DEFAULT LIGHT THEME (STATIC)
  /// =======================================================
  static ThemeData get lightTheme {
    final tones = TonalPalette.from(primaryColor, 1.0, Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: tones.surface,

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: tones.primary,
        onPrimary: tones.onPrimary,
        secondary: tones.primary,
        onSecondary: tones.onPrimary,
        background: tones.surface,
        onBackground: Colors.black87,
        surface: tones.surface,
        onSurface: Colors.black87,
        surfaceVariant: tones.surfaceVariant,
        outline: tones.outline,
        error: errorColor,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardTheme(
        color: tones.surfaceVariant,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: tones.primary,
        thumbColor: tones.primary,
        inactiveTrackColor: tones.outline.withOpacity(0.35),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(tones.primary),
        trackColor: WidgetStateProperty.all(tones.primary.withOpacity(0.45)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tones.primary,
          foregroundColor: tones.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tones.primary,
          side: BorderSide(color: tones.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  /// =======================================================
  /// DYNAMIC LIGHT THEME (COLOR PICKER + SLIDER)
  /// =======================================================
  static ThemeData buildDynamicTheme(ThemeState themeState) {
    final tones = TonalPalette.from(
      themeState.primaryColor,
      themeState.colorIntensity,
      Brightness.light,
    );

    // Use background color based on theme mode
    final backgroundColor =
        themeState.themeMode == ThemeMode.dark
            ? const Color(0xFF121212) // Dark background
            : const Color(0xFFFFFFFF); // Light background

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: tones.primary,
        onPrimary: tones.onPrimary,
        secondary: tones.primary,
        onSecondary: tones.onPrimary,
        background: backgroundColor,
        onBackground: Colors.black87,
        surface: backgroundColor,
        onSurface: Colors.black87,
        surfaceVariant: tones.surfaceVariant,
        outline: tones.outline,
        error: errorColor,
        onError: Colors.white,
      ),

      cardTheme: CardTheme(
        color: tones.surfaceVariant,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 6),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: tones.primary,
        thumbColor: tones.primary,
        inactiveTrackColor: tones.outline.withOpacity(0.3),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(tones.primary),
        trackColor: WidgetStateProperty.all(tones.primary.withOpacity(0.45)),
      ),

      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );
  }

  /// =======================================================
  /// DYNAMIC DARK THEME
  /// =======================================================
  static ThemeData buildDynamicDarkTheme(ThemeState themeState) {
    final tones = TonalPalette.from(
      themeState.primaryColor,
      themeState.colorIntensity,
      Brightness.dark,
    );

    // Use background color based on theme mode
    final backgroundColor =
        themeState.themeMode == ThemeMode.dark
            ? const Color(0xFF121212) // Dark background
            : const Color(0xFFFFFFFF); // Light background

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,

      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: tones.primary,
        onPrimary: Colors.black,
        secondary: tones.primary,
        onSecondary: Colors.black,
        background: backgroundColor,
        onBackground: Colors.white,
        surface: backgroundColor,
        onSurface: Colors.white,
        surfaceVariant: tones.surfaceVariant,
        outline: tones.outline,
        error: errorColor,
        onError: Colors.black,
      ),

      cardTheme: CardTheme(
        color: tones.surfaceVariant,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 6),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: tones.primary,
        thumbColor: tones.primary,
        inactiveTrackColor: tones.outline.withOpacity(0.25),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(tones.primary),
        trackColor: WidgetStateProperty.all(tones.primary.withOpacity(0.4)),
      ),

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
