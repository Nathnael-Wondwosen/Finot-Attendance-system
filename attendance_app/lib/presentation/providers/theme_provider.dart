import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider to manage theme settings
class ThemePreferences {
  static const String themeModeKey = 'theme_mode';
  static const String primaryColorKey = 'primary_color';
  static const String accentColorKey = 'accent_color';
  static const String densityKey = 'app_density';

  static const int defaultPrimaryColor = 0xFF2196F3; // Blue
  static const int defaultAccentColor = 0xFF03DAC6; // Teal
  static const int defaultDensity = 0; // Normal density

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
}

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color accentColor;
  final int density;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
    required this.accentColor,
    required this.density,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? accentColor,
    int? density,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      density: density ?? this.density,
    );
  }
}

final themePreferencesProvider = FutureProvider<ThemePreferences>((ref) async {
  final themePrefs = ThemePreferences();
  await themePrefs.init();
  return themePrefs;
});

final themeStateProvider = StateNotifierProvider<ThemeStateNotifier, ThemeState>(
  (ref) {
    return ThemeStateNotifier(ref);
  },
);

class ThemeStateNotifier extends StateNotifier<ThemeState> {
  final Ref ref;

  ThemeStateNotifier(this.ref) : super(const ThemeState(
    themeMode: ThemeMode.light,
    primaryColor: Color(0xFF2196F3),
    accentColor: Color(0xFF03DAC6),
    density: 0,
  )) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    
    state = state.copyWith(
      themeMode: themePrefs.themeMode,
      primaryColor: themePrefs.primaryColor,
      accentColor: themePrefs.accentColor,
      density: themePrefs.density,
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

  // Reset to default theme
  Future<void> resetToDefault() async {
    final themePrefs = await ref.read(themePreferencesProvider.future);
    await themePrefs.setThemeMode(ThemeMode.light);
    await themePrefs.setPrimaryColor(const Color(0xFF2196F3));
    await themePrefs.setAccentColor(const Color(0xFF03DAC6));
    await themePrefs.setDensity(0);
    
    state = const ThemeState(
      themeMode: ThemeMode.light,
      primaryColor: Color(0xFF2196F3),
      accentColor: Color(0xFF03DAC6),
      density: 0,
    );
  }
}