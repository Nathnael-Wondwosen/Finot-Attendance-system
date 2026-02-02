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
  /// BASE COLORS - Elevated palette
  /// =======================================================
  static const Color primaryColor = Color(0xFF315CFF); // Indigo electric
  static const Color secondaryColor = Color(0xFF1CC8EE); // Aqua accent
  static const Color surfaceSoft = Color(0xFFF7F9FC); // Warm near-white
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textColorPrimary = Color(0xFF0F172A);
  static const Color textColorSecondary = Color(0xFF475569);

  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF0891B2);

  // Neutral ramp for dividers/borders
  static const Color neutralLightest = Color(0xFFF9FAFB);
  static const Color neutralLight = Color(0xFFF1F5F9);
  static const Color neutralMedium = Color(0xFFE2E8F0);
  static const Color neutralDark = Color(0xFFCBD5E1);
  static const Color neutralDarker = Color(0xFF94A3B8);
  static const Color neutralDarkest = Color(0xFF475569);

  /// Spacing + radius tokens for consistent look
  static const double radius = 8;
  static const double radiusSm = 4;
  static const double radiusLg = 12;
  static const double spacing = 16;
  static const double spacingSm = 8;
  static const double spacingLg = 24;

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
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceSoft, // Clean light background

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        background: surfaceSoft,
        onBackground: textColorPrimary,
        surface: surfaceCard,
        onSurface: textColorPrimary,
        surfaceVariant: neutralLight,
        onSurfaceVariant: textColorSecondary,
        outline: neutralDark,
        error: errorColor,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: surfaceCard,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColorPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textColorPrimary),
      ),

      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.06),
        margin: EdgeInsets.symmetric(horizontal: spacingSm, vertical: spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: neutralLight, width: 0.6),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        thumbColor: primaryColor,
        inactiveTrackColor: neutralDark,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(primaryColor),
        trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.35)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing + 2,
            vertical: spacingSm + 2,
          ),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.25),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor.withOpacity(0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: spacing + 2,
            vertical: spacingSm + 2,
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
            ? const Color(0xFF0B1220) // Rich dark
            : surfaceSoft; // Light background

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
        onBackground: textColorPrimary,
        surface: surfaceCard,
        onSurface: textColorPrimary,
        surfaceVariant: tones.surfaceVariant,
        outline: tones.outline,
        error: errorColor,
        onError: Colors.white,
      ),

      cardTheme: CardTheme(
        color: surfaceCard,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 10),
        ),
        surfaceTintColor: Colors.transparent,
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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.applyTone(tones.surface, 1.10),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          borderSide: BorderSide(color: tones.outline.withOpacity(0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          borderSide: BorderSide(color: tones.outline.withOpacity(0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 10),
          borderSide: BorderSide(color: tones.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          letterSpacing: 0.05,
        ),
      ),

      textTheme: ThemeData.light().textTheme
          .apply(
            bodyColor: textColorPrimary,
            displayColor: textColorPrimary,
            fontFamily: 'Roboto',
          )
          .copyWith(
            headlineSmall: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            titleMedium: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
            bodyMedium: const TextStyle(height: 1.5, letterSpacing: 0.05),
            labelLarge: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),

      dividerTheme: DividerThemeData(
        color: tones.outline.withOpacity(0.18),
        space: 24,
        thickness: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tones.primary,
          foregroundColor: tones.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tones.primary,
          side: BorderSide(color: tones.outline.withOpacity(0.6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 4),
        ),
        tileColor: AppTheme.applyTone(tones.surface, 1.06),
        selectedTileColor: tones.primary.withOpacity(0.10),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tones.primary,
        foregroundColor: tones.onPrimary,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 14),
        ),
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
            ? const Color(0xFF0B1220) // Dark background
            : surfaceSoft; // Light background

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
        surface: AppTheme.applyTone(tones.surface, 0.92),
        onSurface: Colors.white,
        surfaceVariant: tones.surfaceVariant,
        outline: tones.outline,
        error: errorColor,
        onError: Colors.black,
      ),

      cardTheme: CardTheme(
        color: AppTheme.applyTone(tones.surface, 0.92),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 10),
        ),
        surfaceTintColor: Colors.transparent,
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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.applyTone(tones.surface, 0.96),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          borderSide: BorderSide(color: tones.outline.withOpacity(0.30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          borderSide: BorderSide(color: tones.outline.withOpacity(0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 10),
          borderSide: BorderSide(color: tones.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
          letterSpacing: 0.1,
        ),
      ),

      textTheme: ThemeData.dark().textTheme
          .apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
            fontFamily: 'Roboto',
          )
          .copyWith(
            headlineSmall: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            titleMedium: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
            bodyMedium: const TextStyle(height: 1.5, letterSpacing: 0.05),
            labelLarge: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),

      dividerTheme: DividerThemeData(
        color: tones.outline.withOpacity(0.26),
        space: 24,
        thickness: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tones.primary,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tones.primary,
          side: BorderSide(color: tones.outline.withOpacity(0.6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeState.cornerRadius + 8),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 4),
        ),
        tileColor: AppTheme.applyTone(tones.surface, 0.94),
        selectedTileColor: tones.primary.withOpacity(0.12),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tones.primary,
        foregroundColor: Colors.black,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeState.cornerRadius + 14),
        ),
      ),
    );
  }

  // Helper method to create consistent text themes
  static TextTheme createTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 92, fontWeight: FontWeight.w300),
      displayMedium: TextStyle(fontSize: 58, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: 46, fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.45),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    );
  }
}
