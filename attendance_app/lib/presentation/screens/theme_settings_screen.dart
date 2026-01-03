import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';
import 'sidebar_drawer.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeStateProvider);
    final primary = theme.primaryColor;

    return SidebarScaffold(
      title: 'Theme Settings',
      navigationItems: [
        const NavigationItem(title: 'Dashboard', icon: Icons.dashboard),
        const NavigationItem(title: 'Classes', icon: Icons.school),
        const NavigationItem(title: 'Summary', icon: Icons.summarize),
        const NavigationItem(title: 'Sync', icon: Icons.sync),
        const NavigationItem(title: 'Settings', icon: Icons.settings),
      ],
      currentIndex: 4, // Settings tab
      onNavigationChanged: (index) {
        _handleNavigation(context, index);
      },
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // ===============================
            // SYSTEM THEME MODE (IMAGE MATCH)
            // ===============================
            _SystemThemeToggle(
              value: theme.themeMode,
              onChanged:
                  (mode) => ref
                      .read(themeStateProvider.notifier)
                      .updateThemeMode(mode),
            ),

            const SizedBox(height: 18),

            // ===============================
            // COLOR PALETTE
            // ===============================
            _SectionLabel('Color theme'),
            const SizedBox(height: 10),
            _ColorPalette(
              selected: primary,
              onSelect:
                  (c) => ref
                      .read(themeStateProvider.notifier)
                      .updatePrimaryColor(c),
            ),

            const SizedBox(height: 18),

            // ===============================
            // ADVANCED APPEARANCE CARD
            // ===============================
            _AdvancedAppearanceCard(
              primary: primary,
              intensity: theme.colorIntensity,
              onIntensityChanged: (v) {
                ref.read(themeStateProvider.notifier).updateColorIntensity(v);
              },
            ),

            const SizedBox(height: 18),

            // ===============================
            // FONT SIZE ADJUSTMENT
            // ===============================
            _SectionLabel('Font Size'),
            const SizedBox(height: 10),
            _FontSizeSlider(
              fontSizeScale: theme.fontSizeScale,
              onFontSizeChanged: (v) {
                ref.read(themeStateProvider.notifier).updateFontSizeScale(v);
              },
            ),

            const SizedBox(height: 18),

            // ===============================
            // CORNER RADIUS ADJUSTMENT
            // ===============================
            _SectionLabel('Corner Radius'),
            const SizedBox(height: 10),
            _CornerRadiusSlider(
              cornerRadius: theme.cornerRadius,
              onCornerRadiusChanged: (v) {
                ref.read(themeStateProvider.notifier).updateCornerRadius(v);
              },
            ),

            const SizedBox(height: 18),

            // ===============================
            // BACKGROUND SETTINGS
            // ===============================
            _SectionLabel('Background'),
            const SizedBox(height: 10),
            _BackgroundSettings(
              useGradient: theme.useGradientBackground,
              backgroundColor: theme.backgroundColor,
              onGradientChanged: (v) {
                ref
                    .read(themeStateProvider.notifier)
                    .updateUseGradientBackground(v);
              },
              onBackgroundColorChanged: (color) {
                ref
                    .read(themeStateProvider.notifier)
                    .updateBackgroundColor(color);
              },
            ),

            const SizedBox(height: 18),

            // ===============================
            // DENSITY
            // ===============================
            _SectionLabel('Display density'),
            const SizedBox(height: 8),
            _DensitySelector(
              value: theme.density,
              onChanged:
                  (v) => ref.read(themeStateProvider.notifier).updateDensity(v),
            ),

            const SizedBox(height: 18),

            // ===============================
            // RESET TO DEFAULTS
            // ===============================
            _SectionLabel('Reset'),
            const SizedBox(height: 10),
            _ResetButton(
              onReset: () {
                ref.read(themeStateProvider.notifier).resetToDefaults();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClassSelectionScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AttendanceSummaryScreen(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SyncStatusScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }
}

/// =======================================================
/// SYSTEM / LIGHT / DARK (LIKE IMAGE)
/// =======================================================
class _SystemThemeToggle extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _SystemThemeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _toggle('System', ThemeMode.system),
          _toggle('Light', ThemeMode.light),
          _toggle('Dark', ThemeMode.dark),
        ],
      ),
    );
  }

  Widget _toggle(String label, ThemeMode mode) {
    final selected = value == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// COLOR PALETTE (MATCH IMAGE)
/// =======================================================
class _ColorPalette extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorPalette({required this.selected, required this.onSelect});

  static const _colors = [
    Color(0xFF0B5ED7),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF795548),
    Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          _colors.map((c) {
            final isSelected = c.value == selected.value;

            return GestureDetector(
              onTap: () => onSelect(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: c.withOpacity(0.45),
                              blurRadius: 12,
                            ),
                          ]
                          : [],
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}

/// =======================================================
/// ADVANCED APPEARANCE (LIKE IMAGE)
/// =======================================================
class _AdvancedAppearanceCard extends StatelessWidget {
  final Color primary;
  final double intensity;
  final ValueChanged<double> onIntensityChanged;

  const _AdvancedAppearanceCard({
    required this.primary,
    required this.intensity,
    required this.onIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Advanced appearance',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const Icon(Icons.expand_more),
              ],
            ),

            const SizedBox(height: 12),

            // SLIDER
            Slider(
              value: intensity,
              min: 0.5,
              max: 1.0,
              divisions: 10,
              activeColor: primary,
              onChanged: onIntensityChanged,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                intensity < 0.65
                    ? 'Soft'
                    : intensity < 0.85
                    ? 'Balanced'
                    : 'Vivid',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// FONT SIZE SLIDER
/// =======================================================
class _FontSizeSlider extends StatelessWidget {
  final double fontSizeScale;
  final ValueChanged<double> onFontSizeChanged;

  const _FontSizeSlider({
    required this.fontSizeScale,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Small', style: TextStyle(fontSize: 12)),
              Text(
                'Font Size: ${(fontSizeScale * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text('Large', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: fontSizeScale,
            min: 0.8,
            max: 1.3,
            divisions: 10,
            label: '${(fontSizeScale * 100).round()}%',
            onChanged: onFontSizeChanged,
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// CORNER RADIUS SLIDER
/// =======================================================
class _CornerRadiusSlider extends StatelessWidget {
  final double cornerRadius;
  final ValueChanged<double> onCornerRadiusChanged;

  const _CornerRadiusSlider({
    required this.cornerRadius,
    required this.onCornerRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sharp', style: TextStyle(fontSize: 12)),
              Text(
                'Rounded Corners: ${cornerRadius.round()}px',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text('Rounded', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: cornerRadius,
            min: 4.0,
            max: 24.0,
            divisions: 20,
            label: '${cornerRadius.round()}px',
            onChanged: onCornerRadiusChanged,
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// BACKGROUND SETTINGS
/// =======================================================
class _BackgroundSettings extends StatelessWidget {
  final bool useGradient;
  final Color backgroundColor;
  final ValueChanged<bool> onGradientChanged;
  final ValueChanged<Color> onBackgroundColorChanged;

  const _BackgroundSettings({
    required this.useGradient,
    required this.backgroundColor,
    required this.onGradientChanged,
    required this.onBackgroundColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background Settings',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Use Gradient Background'),
            value: useGradient,
            onChanged: onGradientChanged,
          ),
          const SizedBox(height: 8),
          const Text('Background Color:'),
          const SizedBox(height: 8),
          _ColorPicker(
            selectedColor: backgroundColor,
            onColorChanged: onBackgroundColorChanged,
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// COLOR PICKER
/// =======================================================
class _ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.grey.shade50,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.pink.shade50,
      Colors.purple.shade50,
      Colors.orange.shade50,
      Colors.teal.shade50,
      Colors.amber.shade50,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          colors.map((color) {
            final isSelected = color.value == selectedColor.value;
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
            );
          }).toList(),
    );
  }
}

/// =======================================================
/// RESET BUTTON
/// =======================================================
class _ResetButton extends StatelessWidget {
  final VoidCallback onReset;

  const _ResetButton({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset to Defaults'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

/// =======================================================
/// DENSITY SELECTOR
/// =======================================================
class _DensitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DensitySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _item('Compact', -1),
        const SizedBox(width: 8),
        _item('Default', 0),
        const SizedBox(width: 8),
        _item('Comfort', 1),
      ],
    );
  }

  Widget _item(String label, int v) {
    final selected = v == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// SECTION LABEL
/// =======================================================
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Colors.grey,
      ),
    );
  }
}
