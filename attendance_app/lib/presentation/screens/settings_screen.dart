import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../providers/theme_provider.dart';
import 'theme_settings_screen.dart';
import 'sidebar_drawer.dart';
import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 8),

        // 🔹 PERSONALIZATION
        _SectionTitle(title: 'Personalization'),
        _GlassSettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Theme Settings',
              subtitle: 'Colors, dark mode & density',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                );
              },
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.view_compact_alt_outlined,
              title: 'Compact Mode',
              subtitle: 'Denser layout for advanced users',
              value:
                  themeState.density !=
                  0, // If density is not normal (0), then compact mode is on
              onChanged: (v) {
                ref.read(themeStateProvider.notifier).updateDensity(v ? 1 : 0);
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 🔹 GENERAL
        _SectionTitle(title: 'General'),
        _GlassSettingsCard(
          children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Attendance & system alerts',
              value: true, // Using a simple state for now
              onChanged: (v) {
                // Handle notification toggle
              },
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'Change application language',
              onTap: () {
                // future language page
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 🔹 SECURITY
        _SectionTitle(title: 'Security'),
        _GlassSettingsCard(
          children: [
            _SwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Lock',
              subtitle: 'Secure app with fingerprint / face',
              value: false, // Using a simple state for now
              onChanged: (v) {
                // Handle biometric toggle
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 🔹 ABOUT
        _SectionTitle(title: 'About'),
        _GlassSettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About Application',
              subtitle: 'Version, build & credits',
              onTap: () {
                // about page
              },
            ),
            _Divider(),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Policies and legal information',
              onTap: () {
                // terms page
              },
            ),
          ],
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: Colors.grey,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
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
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.blue),
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
