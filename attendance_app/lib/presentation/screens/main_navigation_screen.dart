import 'dart:ui';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';
import 'sidebar_drawer.dart';

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
    NavigationItem(title: 'Dashboard', icon: Icons.dashboard_rounded),
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
          body: SidebarScaffold(
            title: _navigationItems[_selectedIndex].title,
            navigationItems: _navigationItems,
            currentIndex: _selectedIndex,
            primaryColor: primary,
            onNavigationChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),

          /// MOBILE FUTURISTIC BOTTOM NAV
          bottomNavigationBar:
              showSidebar
                  ? null
                  : FuturisticBottomTabs(
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() => _selectedIndex = index);
                    },
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final height = screenWidth < 375 ? 56.0 : 64.0; // Compact on small screens
    final borderRadius = screenWidth < 375 ? 24.0 : 28.0;
    final paddingHorizontal = screenWidth < 375 ? 8.0 : 12.0;
    final iconSize = screenWidth < 375 ? 16.0 : 18.0;
    final fontSize = screenWidth < 375 ? 8.0 : 9.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        bottomInset + 12,
      ), // Reduced padding for compact feel
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius,
        ), // Responsive rounding
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ), // Slightly reduced blur for cleaner look
          child: Container(
            height: height, // Reduced height for compact design
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color:
                  isDark
                      ? const Color(0xFF0B1224).withOpacity(
                        0.95,
                      ) // Slightly reduced opacity
                      : Colors.white.withOpacity(
                        0.92,
                      ), // Slightly reduced opacity
              // Remove border to match user preference for no border lines
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.15,
                  ), // Reduced shadow for subtlety
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON CONTAINER (COMPACT SIZE)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, selected ? -1 : 0, 0),
                width: iconSize * 2,
                height: iconSize * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected
                          ? primary
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05)),
                ),
                child: Icon(
                  item.icon,
                  size: iconSize,
                  color:
                      selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),

              /// LABEL (ONLY WHEN ACTIVE - COMPACT)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child:
                    selected
                        ? Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            item.label,
                            key: ValueKey(item.label),
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
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
