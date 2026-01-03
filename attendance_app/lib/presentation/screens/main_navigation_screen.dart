import 'dart:ui';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';
import 'sidebar_drawer.dart';
import 'top_scaffold.dart';

/// =======================================================
/// MAIN NAVIGATION SCREEN
/// =======================================================
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  /// SINGLE SOURCE OF TRUTH (SIDEBAR + TABS) - MODERN ICONS
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(title: 'Home', icon: Icons.dashboard_rounded),
    NavigationItem(title: 'Classes', icon: Icons.school_rounded),
    NavigationItem(title: 'Attendance', icon: Icons.check_circle_rounded),
    NavigationItem(title: 'Sync', icon: Icons.cloud_sync_rounded),
    NavigationItem(title: 'Settings', icon: Icons.settings_rounded),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    ClassSelectionScreen(),
    AttendanceSummaryScreen(),
    SyncStatusScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSidebar = constraints.maxWidth >= 768;

        return Scaffold(
          body:
              showSidebar
                  ? SidebarScaffold(
                    title: _navigationItems[_selectedIndex].title,
                    navigationItems: _navigationItems,
                    currentIndex: _selectedIndex,
                    primaryColor: primary,
                    onNavigationChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  )
                  : TopScaffold(
                    title: _navigationItems[_selectedIndex].title,
                    navigationItems: _navigationItems,
                    currentIndex: _selectedIndex,
                    primaryColor: primary,
                    onNavigationChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  ),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////
/// COMPACT FUTURISTIC BOTTOM TABS (RESPONSIVE MINIMIZED)
////////////////////////////////////////////////////////////////
class FuturisticBottomTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FuturisticBottomTabs({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_TabItem> _items = [
    _TabItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    _TabItem(label: 'Classes', icon: Icons.school_rounded),
    _TabItem(label: 'Attendance', icon: Icons.check_circle_rounded),
    _TabItem(label: 'Sync', icon: Icons.cloud_sync_rounded),
    _TabItem(label: 'Settings', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Theme-driven sizing – use text theme and icon theme so users can customize via Theme Settings
    final height = screenWidth < 375 ? 56.0 : 64.0; // compact baseline
    final paddingHorizontal = screenWidth < 375 ? 8.0 : 12.0;
    final iconSize = (theme.textTheme.labelLarge?.fontSize ?? 14.0) * 1.2;
    final fontSize = theme.textTheme.labelLarge?.fontSize ?? 14.0;

    final navBackground = theme.colorScheme.surface.withOpacity(
      isDark ? 0.92 : 0.92,
    );
    final navTopBorder = theme.colorScheme.onSurface.withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottomInset),
      height: height + bottomInset,
      decoration: BoxDecoration(
        color: navBackground,
        border: Border(top: BorderSide(color: navTopBorder)),
      ),
      child: Row(
        children: List.generate(
          _items.length,
          (index) => _CompactFuturisticTabButton(
            item: _items[index],
            selected: index == currentIndex,
            onTap: () => onTap(index),
            iconSize: iconSize,
            fontSize: fontSize,
            paddingHorizontal: paddingHorizontal,
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// COMPACT TAB BUTTON (RESPONSIVE MINIMIZED)
////////////////////////////////////////////////////////////////
class _CompactFuturisticTabButton extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final double paddingHorizontal;

  const _CompactFuturisticTabButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    required this.fontSize,
    required this.paddingHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final iconContainerSize = iconSize * 2;
    final bgColor =
        selected
            ? primary
            : (isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05));
    final iconColor =
        selected
            ? theme.colorScheme.onPrimary
            : (isDark ? Colors.white70 : Colors.black87);
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? primary : (isDark ? Colors.white70 : Colors.black54),
    );

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(
          0,
        ), // no rounding per global preference
        onTap: onTap,
        child: SizedBox(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableH = constraints.maxHeight;
              final iconH = iconContainerSize.clamp(0.0, availableH * 0.6);
              final iconSizeAdjusted = iconSize.clamp(0.0, iconH * 0.9);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// ICON CONTAINER (COMPACT SIZE)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                      0,
                      selected ? -1 : 0,
                      0,
                    ),
                    width: iconH,
                    height: iconH,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                    ),
                    child: Icon(
                      item.icon,
                      size: iconSizeAdjusted,
                      color: iconColor,
                    ),
                  ),

                  /// LABEL (ONLY WHEN ACTIVE - COMPACT)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child:
                        selected
                            ? Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 64),
                                child: Text(
                                  item.label,
                                  key: ValueKey(item.label),
                                  style: labelStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// TAB ITEM MODEL
////////////////////////////////////////////////////////////////
class _TabItem {
  final String label;
  final IconData icon;

  const _TabItem({required this.label, required this.icon});
}
