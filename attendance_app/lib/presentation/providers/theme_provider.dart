import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider to manage theme settings
class ThemePreferences {
  static const String themeModeKey = 'theme_mode';
  static const String primaryColorKey = 'primary_color';
  static const String accentColorKey = 'accent_color';
  static const String densityKey = 'app_density';
  static const String colorIntensityKey = 'color_intensity';
  static const String fontSizeScaleKey = 'font_size_scale';
  static const String cornerRadiusKey = 'corner_radius';
  static const String useGradientBackgroundKey = 'use_gradient_background';
  static const String backgroundColorKey = 'background_color';

  static const int defaultPrimaryColor = 0xFF2196F3; // Blue
  static const int defaultAccentColor = 0xFF03DAC6; // Teal
  static const int defaultDensity = 0; // Normal density
  static const double defaultColorIntensity = 0.8;
  static const double defaultFontSizeScale = 1.0;
  static const double defaultCornerRadius = 8.0;
  static const bool defaultUseGradientBackground = false;
  static const int defaultBackgroundColor = 0xFFF5F5F5; // Grey 50

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ThemeMode get themeMode {
    final themeIndex = _prefs.getInt(themeModeKey) ?? ThemeMode.light.index;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setInt(themeModeKey, themeMode.index);
  }

  Color get primaryColor {
    return Color(_prefs.getInt(primaryColorKey) ?? defaultPrimaryColor);
  }

  Future<void> setPrimaryColor(Color color) async {
    await _prefs.setInt(primaryColorKey, color.value);
  }

  Color get accentColor {
    return Color(_prefs.getInt(accentColorKey) ?? defaultAccentColor);
  }

  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(accentColorKey, color.value);
  }

  int get density {
    return _prefs.getInt(densityKey) ?? defaultDensity;
  }

  Future<void> setDensity(int density) async {
    await _prefs.setInt(densityKey, density);
  }

  // New theme properties
  double get colorIntensity {
    return _prefs.getDouble(colorIntensityKey) ?? defaultColorIntensity;
  }

  Future<void> setColorIntensity(double intensity) async {
    await _prefs.setDouble(colorIntensityKey, intensity);
  }

  double get fontSizeScale {
    return _prefs.getDouble(fontSizeScaleKey) ?? defaultFontSizeScale;
  }

  Future<void> setFontSizeScale(double scale) async {
    await _prefs.setDouble(fontSizeScaleKey, scale);
  }

  double get cornerRadius {
    return _prefs.getDouble(cornerRadiusKey) ?? defaultCornerRadius;
  }

  Future<void> setCornerRadius(double radius) async {
    await _prefs.setDouble(cornerRadiusKey, radius);
  }

  bool get useGradientBackground {
    return _prefs.getBool(useGradientBackgroundKey) ??
        defaultUseGradientBackground;
  }

  Future<void> setUseGradientBackground(bool useGradient) async {
    await _prefs.setBool(useGradientBackgroundKey, useGradient);
  }

  Color get backgroundColor {
    return Color(_prefs.getInt(backgroundColorKey) ?? defaultBackgroundColor);
  }

  Future<void> setBackgroundColor(Color color) async {
    await _prefs.setInt(backgroundColorKey, color.value);
  }
}

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color accentColor;
  final int density;
  final double colorIntensity;
  final double fontSizeScale;
  final double cornerRadius;
  final bool useGradientBackground;
  final Color backgroundColor;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
    required this.accentColor,
    required this.density,
    this.colorIntensity = 0.8,
    this.fontSizeScale = 1.0,
    this.cornerRadius = 8.0,
    this.useGradientBackground = false,
    this.backgroundColor = const Color(0xFFF5F5F5),
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? accentColor,
    int? density,
    double? colorIntensity,
    double? fontSizeScale,
    double? cornerRadius,
    bool? useGradientBackground,
    Color? backgroundColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      density: density ?? this.density,
      colorIntensity: colorIntensity ?? this.colorIntensity,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      useGradientBackground:
          useGradientBackground ?? this.useGradientBackground,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

final themePreferencesProvider = FutureProvider<ThemePreferences>((ref) async {
  final themePrefs = ThemePreferences();
  await themePrefs.init();
  return themePrefs;
});

final themeStateProvider =
    StateNotifierProvider<ThemeStateNotifier, ThemeState>((ref) {
      return ThemeStateNotifier(ref);
    });

class ThemeStateNotifier extends StateNotifier<ThemeState> {
  final Ref ref;

  ThemeStateNotifier(this.ref)
    : super(
        const ThemeState(
          themeMode: ThemeMode.light,
          primaryColor: Color(0xFF2196F3),
          accentColor: Color(0xFF03DAC6),
          density: 0,
        ),
      ) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final themePrefs = await ref.read(themePreferencesProvider.future);

    state = state.copyWith(
      themeMode: themePrefs.themeMode,
      primaryColor: themePrefs.primaryColor,
      accentColor: themePrefs.accentColor,
      density: themePrefs.density,
      colorIntensity: themePrefs.colorIntensity,
      fontSizeScale: themePrefs.fontSizeScale,
      cornerRadius: themePrefs.cornerRadius,
      useGradientBackground: themePrefs.useGradientBackground,
      backgroundColor: themePrefs.backgroundColor,
    );
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> updatePrimaryColor(Color color) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setPrimaryColor(color);
    state = state.copyWith(primaryColor: color);
  }

  Future<void> updateAccentColor(Color color) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setAccentColor(color);
    state = state.copyWith(accentColor: color);
  }

  Future<void> updateDensity(int density) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setDensity(density);
    state = state.copyWith(density: density);
  }

  // New update methods for advanced theming
  Future<void> updateColorIntensity(double intensity) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setColorIntensity(intensity);
    state = state.copyWith(colorIntensity: intensity);
  }

  Future<void> updateFontSizeScale(double scale) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setFontSizeScale(scale);
    state = state.copyWith(fontSizeScale: scale);
  }

  Future<void> updateCornerRadius(double radius) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setCornerRadius(radius);
    state = state.copyWith(cornerRadius: radius);
  }

  Future<void> updateUseGradientBackground(bool useGradient) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setUseGradientBackground(useGradient);
    state = state.copyWith(useGradientBackground: useGradient);
  }

  Future<void> updateBackgroundColor(Color color) async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setBackgroundColor(color);
    state = state.copyWith(backgroundColor: color);
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setThemeMode(ThemeMode.light);
    await themePrefs.setPrimaryColor(const Color(0xFF2196F3));
    await themePrefs.setAccentColor(const Color(0xFF03DAC6));
    await themePrefs.setDensity(0);
    await themePrefs.setColorIntensity(0.8);
    await themePrefs.setFontSizeScale(1.0);
    await themePrefs.setCornerRadius(8.0);
    await themePrefs.setUseGradientBackground(false);
    await themePrefs.setBackgroundColor(const Color(0xFFF5F5F5));

    state = const ThemeState(
      themeMode: ThemeMode.light,
      primaryColor: Color(0xFF2196F3),
      accentColor: Color(0xFF03DAC6),
      density: 0,
      colorIntensity: 0.8,
      fontSizeScale: 1.0,
      cornerRadius: 8.0,
      useGradientBackground: false,
      backgroundColor: Color(0xFFF5F5F5),
    );
  }

  // Convenience method to reset to defaults
  Future<void> resetToDefaults() async {
    await resetToDefault();
  }
}
