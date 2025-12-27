import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeModeSelector(themeState, ref),
            const SizedBox(height: 32),
            const Text(
              'Primary Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorSelector(
              themeState.primaryColor,
              'Primary',
              (color) => ref.read(themeStateProvider.notifier).updatePrimaryColor(color),
            ),
            const SizedBox(height: 32),
            const Text(
              'Accent Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorSelector(
              themeState.accentColor,
              'Accent',
              (color) => ref.read(themeStateProvider.notifier).updateAccentColor(color),
            ),
            const SizedBox(height: 32),
            const Text(
              'App Density',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDensitySelector(themeState, ref),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Reset to Default',
              onPressed: () => ref.read(themeStateProvider.notifier).resetToDefault(),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(ThemeState themeState, WidgetRef ref) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.settings),
        ),
      ],
      selected: {themeState.themeMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        if (newSelection.isNotEmpty) {
          ref.read(themeStateProvider.notifier).updateThemeMode(newSelection.first);
        }
      },
    );
  }

  Widget _buildColorSelector(Color currentColor, String label, Function(Color) onColorChanged) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Current $label Color',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          PopupMenuButton<Color>(
            itemBuilder: (context) => [
              _buildColorItem(Colors.red, 'Red'),
              _buildColorItem(Colors.blue, 'Blue'),
              _buildColorItem(Colors.green, 'Green'),
              _buildColorItem(Colors.purple, 'Purple'),
              _buildColorItem(Colors.orange, 'Orange'),
              _buildColorItem(Colors.pink, 'Pink'),
              _buildColorItem(Colors.indigo, 'Indigo'),
              _buildColorItem(Colors.teal, 'Teal'),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Change'),
            ),
            onSelected: (Color color) => onColorChanged(color),
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<Color> _buildColorItem(Color color, String label) {
    return PopupMenuItem(
      value: color,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildDensitySelector(ThemeState themeState, WidgetRef ref) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(
          value: -1,
          label: Text('Compact'),
        ),
        ButtonSegment(
          value: 0,
          label: Text('Normal'),
        ),
        ButtonSegment(
          value: 1,
          label: Text('Expanded'),
        ),
      ],
      selected: {themeState.density},
      onSelectionChanged: (Set<int> newSelection) {
        if (newSelection.isNotEmpty) {
          ref.read(themeStateProvider.notifier).updateDensity(newSelection.first);
        }
      },
    );
  }
}