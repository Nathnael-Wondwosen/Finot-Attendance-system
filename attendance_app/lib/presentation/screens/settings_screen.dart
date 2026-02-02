import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    final theme = Theme.of(context);

    return SoftGradientBackground(
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HeroHeader(themeState: themeState, ref: ref),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            // PERSONALIZATION
            SliverToBoxAdapter(
              child: _SettingsGroup(
                title: 'Personalization',
                children: [
                  _ExpandableThemeSettings(themeState: themeState, ref: ref),
                  _Divider(),
                  _SwitchTile(
                    icon: Icons.view_compact_alt_outlined,
                    title: 'Compact Mode',
                    subtitle: 'Denser layout for expert users',
                    value: themeState.density != 0,
                    onChanged: (v) {
                      ref.read(themeStateProvider.notifier).updateDensity(
                        v ? 1 : 0,
                      );
                    },
                  ),
                ],
              ),
            ),

            // EXPERIENCE
            SliverToBoxAdapter(
              child: _SettingsGroup(
                title: 'Experience',
                children: [
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Attendance & system alerts',
                    value: true,
                    onChanged: (v) {},
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'Change application language',
                    onTap: () {},
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Accent presets',
                    subtitle: 'Pick from curated palettes',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // SECURITY
            SliverToBoxAdapter(
              child: _SettingsGroup(
                title: 'Security',
                children: [
                  _SwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric Lock',
                    subtitle: 'Secure app with fingerprint / face',
                    value: false,
                    onChanged: (v) {},
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Data protection',
                    subtitle: 'Local data stays on device; no login required',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ABOUT
            SliverToBoxAdapter(
              child: _SettingsGroup(
                title: 'About',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Application',
                    subtitle: 'Version 1.0.0 • Finot Attendance',
                    onTap: () {},
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Privacy',
                    subtitle: 'Policies and legal information',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
    );
  }
}

/// =======================================================
/// HEADER
/// =======================================================
class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Attendance System',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'System preferences & configuration',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// SECTION TITLE
/// =======================================================
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.35),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// GLASS CARD
/// =======================================================
class _GlassSettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _GlassSettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// SETTINGS TILE
/// =======================================================
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBox(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// SWITCH TILE
/// =======================================================
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// =======================================================
/// ICON BOX
/// =======================================================
class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: primary),
    );
  }
}

/// =======================================================
/// DIVIDER
/// =======================================================
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}

/// =======================================================
/// EXPANDABLE THEME SETTINGS
/// =======================================================
class _ExpandableThemeSettings extends ConsumerStatefulWidget {
  final ThemeState themeState;
  final WidgetRef ref;

  const _ExpandableThemeSettings({required this.themeState, required this.ref});

  @override
  ConsumerState<_ExpandableThemeSettings> createState() =>
      _ExpandableThemeSettingsState();
}

class _ExpandableThemeSettingsState
    extends ConsumerState<_ExpandableThemeSettings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header - Expandable Tile
        InkWell(
          onTap: _toggleExpansion,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _IconBox(icon: Icons.color_lens_outlined),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme Settings',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Colors, dark mode & appearance',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                  child: const Icon(Icons.expand_more, size: 24),
                ),
              ],
            ),
          ),
        ),

        // Expanded Content
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                border: const Border(top: BorderSide(color: Colors.white24)),
              ),
              child: Column(
                children: [
                  // Dark Mode Toggle
                  _ThemeToggleTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: widget.themeState.themeMode == ThemeMode.dark,
                    onChanged: (v) {
                      widget.ref
                          .read(themeStateProvider.notifier)
                          .updateThemeMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),

                  // Primary Color Picker
                  _ThemeOptionTile(
                    icon: Icons.palette_outlined,
                    title: 'Primary Color',
                    subtitle: _getColorName(widget.themeState.primaryColor),
                    onTap:
                        () => _showColorPicker(context, 'Primary Color', true),
                  ),

                  // Accent Color Picker
                  _ThemeOptionTile(
                    icon: Icons.format_color_fill_outlined,
                    title: 'Accent Color',
                    subtitle: _getColorName(widget.themeState.accentColor),
                    onTap:
                        () => _showColorPicker(context, 'Accent Color', false),
                  ),

                  // Font Size Slider
                  _ThemeSliderTile(
                    icon: Icons.text_fields_outlined,
                    title: 'Font Size',
                    value: widget.themeState.fontSizeScale,
                    min: 0.8,
                    max: 1.4,
                    onChanged: (v) {
                      widget.ref
                          .read(themeStateProvider.notifier)
                          .updateFontSizeScale(v);
                    },
                  ),

                  // Corner Radius Slider
                  _ThemeSliderTile(
                    icon: Icons.rounded_corner_outlined,
                    title: 'Corner Roundness',
                    value: widget.themeState.cornerRadius,
                    min: 0,
                    max: 20,
                    onChanged: (v) {
                      widget.ref
                          .read(themeStateProvider.notifier)
                          .updateCornerRadius(v);
                    },
                  ),

                  // Reset Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.ref
                            .read(themeStateProvider.notifier)
                            .resetToDefaults();
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Reset to Defaults'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getColorName(Color color) {
    final Map<Color, String> colorNames = {
      const Color(0xFF2196F3): 'Blue',
      const Color(0xFFE91E63): 'Pink',
      const Color(0xFF4CAF50): 'Green',
      const Color(0xFFFF9800): 'Orange',
      const Color(0xFF9C27B0): 'Purple',
      const Color(0xFF00BCD4): 'Cyan',
      const Color(0xFFFF5722): 'Deep Orange',
      const Color(0xFF607D8B): 'Blue Grey',
    };

    return colorNames[color] ?? 'Custom';
  }

  void _showColorPicker(BuildContext context, String title, bool isPrimary) {
    final List<Color> colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFFE91E63), // Pink
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF607D8B), // Blue Grey
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    return GestureDetector(
                      onTap: () {
                        if (isPrimary) {
                          widget.ref
                              .read(themeStateProvider.notifier)
                              .updatePrimaryColor(color);
                        } else {
                          widget.ref
                              .read(themeStateProvider.notifier)
                              .updateAccentColor(color);
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

/// Theme Toggle Tile
class _ThemeToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ThemeToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _SmallIconBox(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Theme Option Tile (for navigation)
class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SmallIconBox(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Theme Slider Tile
class _ThemeSliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ThemeSliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SmallIconBox(icon: icon),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).toInt(),
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

/// Small Icon Box
class _SmallIconBox extends StatelessWidget {
  final IconData icon;

  const _SmallIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: primary, size: 18),
    );
  }
}

/// =======================================================
/// WRAPPERS
/// =======================================================
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title),
          const SizedBox(height: 6),
          _GlassSettingsCard(children: children),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final ThemeState themeState;
  final WidgetRef ref;

  const _HeroHeader({required this.themeState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Finot Attendance',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fine-tune your offline-first experience.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeaderPill(
                    label: 'Theme',
                    value:
                        themeState.themeMode == ThemeMode.dark
                            ? 'Dark'
                            : 'Light',
                    icon: Icons.dark_mode_outlined,
                  ),
                  const SizedBox(width: 10),
                  _HeaderPill(
                    label: 'Accent',
                    value: _colorName(themeState.primaryColor),
                    icon: Icons.palette_outlined,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(themeStateProvider.notifier)
                          .resetToDefaults();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _colorName(Color color) {
    final Map<Color, String> colorNames = {
      const Color(0xFF2196F3): 'Blue',
      const Color(0xFFE91E63): 'Pink',
      const Color(0xFF4CAF50): 'Green',
      const Color(0xFFFF9800): 'Orange',
      const Color(0xFF9C27B0): 'Purple',
      const Color(0xFF00BCD4): 'Cyan',
      const Color(0xFFFF5722): 'Deep Orange',
      const Color(0xFF607D8B): 'Blue Grey',
      const Color(0xFF2D6CF6): 'Finot Blue',
    };
    return colorNames[color] ?? 'Custom';
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
