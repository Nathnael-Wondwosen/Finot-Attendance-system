import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';

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

  final List<Widget> _screens = [
    DashboardScreen(),
    ClassSelectionScreen(),
    AttendanceSummaryScreen(),
    SyncStatusScreen(),
    SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavBarItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      activeIcon: Icon(Icons.home, color: Colors.blue),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school),
      activeIcon: Icon(Icons.school, color: Colors.blue),
      label: 'Classes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      activeIcon: Icon(Icons.bar_chart, color: Colors.blue),
      label: 'Attendance',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sync),
      activeIcon: Icon(Icons.sync, color: Colors.blue),
      label: 'Sync',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      activeIcon: Icon(Icons.settings, color: Colors.blue),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: _bottomNavBarItems,
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected ? activeColor.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: selected ? 38 : 30,
                  height: selected ? 38 : 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selected
                            ? activeColor.withOpacity(0.18)
                            : colorScheme.onSurface.withOpacity(0.04),
                  ),
                ),
                Icon(
                  item.icon,
                  size: selected ? 22 : 20,
                  color:
                      selected
                          ? activeColor
                          : colorScheme.onSurface.withOpacity(0.65),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected
                        ? activeColor
                        : colorScheme.onSurface.withOpacity(0.65),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
