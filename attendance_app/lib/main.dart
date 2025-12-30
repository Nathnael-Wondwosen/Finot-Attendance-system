import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/class_selection_screen.dart';
import 'presentation/screens/attendance_screen.dart';
import 'presentation/screens/attendance_summary_screen.dart'; // Import the new summary screen
import 'presentation/screens/sync_status_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'core/theme.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finot Attendance System',
      theme: AppTheme.lightTheme,
      themeMode:
          ThemeMode
              .light, // Changed to light mode only since darkTheme is not defined
      debugShowCheckedModeBanner: false,
      home:
          const MainScreen(), // Use a main screen that contains bottom navigation
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Define all the screens
  final List<Widget> _screens = [
    DashboardScreen(),
    const ClassSelectionScreen(),
    const AttendanceSummaryScreen(), // Using summary as attendance screen for now
    const SyncStatusScreen(),
    const SettingsScreen(),
  ];

  // Define bottom navigation items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    const BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.check_circle),
      label: 'Attendance',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to update the selected tab from other screens
  void updateSelectedTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Fixed type for 5 items
      ),
    );
  }
}
