import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/ui_components.dart';
import '../providers/theme_provider.dart';
import '../../core/sync_service.dart';
import '../providers/app_provider.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Primary Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildColorOption(
                          themeState.primaryColor,
                          AppTheme.primaryColor,
                          'Blue',
                        ),
                        const SizedBox(width: 8),
                        _buildColorOption(
                          themeState.primaryColor,
                          Colors.green,
                          'Green',
                        ),
                        const SizedBox(width: 8),
                        _buildColorOption(
                          themeState.primaryColor,
                          Colors.purple,
                          'Purple',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Accent Color'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildColorOption(
                          themeState.accentColor,
                          AppTheme.secondaryColor,
                          'Blue',
                        ),
                        const SizedBox(width: 8),
                        _buildColorOption(
                          themeState.accentColor,
                          Colors.green,
                          'Green',
                        ),
                        const SizedBox(width: 8),
                        _buildColorOption(
                          themeState.accentColor,
                          Colors.purple,
                          'Purple',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Theme Mode'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildThemeModeOption(ThemeMode.light, 'Light'),
                        const SizedBox(width: 8),
                        _buildThemeModeOption(ThemeMode.dark, 'Dark'),
                        const SizedBox(width: 8),
                        _buildThemeModeOption(ThemeMode.system, 'System'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Density'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDensityOption(-1, 'Compact'),
                        const SizedBox(width: 8),
                        _buildDensityOption(0, 'Normal'),
                        const SizedBox(width: 8),
                        _buildDensityOption(1, 'Expanded'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clear Local Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will remove all downloaded classes and student data from your device. You can re-download them when needed.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _clearLocalData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear All Data'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    Color currentColor,
    Color optionColor,
    String label,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => _updateColor(optionColor),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: optionColor,
            border: Border.all(
              color:
                  currentColor == optionColor
                      ? Colors.black
                      : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeOption(ThemeMode mode, String label) {
    final themeState = ref.watch(themeStateProvider);
    final isSelected = themeState.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => _updateThemeMode(mode),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDensityOption(int density, String label) {
    final themeState = ref.watch(themeStateProvider);
    final isSelected = themeState.density == density;

    return Expanded(
      child: InkWell(
        onTap: () => _updateDensity(density),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateColor(Color color) {
    ref.read(themeStateProvider.notifier).updatePrimaryColor(color);
  }

  void _updateThemeMode(ThemeMode mode) {
    ref.read(themeStateProvider.notifier).updateThemeMode(mode);
  }

  void _updateDensity(int density) {
    ref.read(themeStateProvider.notifier).updateDensity(density);
  }

  Future<void> _clearLocalData() async {
    final syncService = ref.read(syncServiceProvider);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Local Data'),
            content: const Text(
              'Are you sure you want to clear all downloaded data? This will remove all classes and students from your device. You can re-download them later when needed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Clear Data',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await syncService.clearLocalData();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Local data cleared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to clear local data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing local data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
