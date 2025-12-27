import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';

// Dashboard screen with improved UI and responsive design
// Following user preferences for simplicity, clean aesthetics, and role-based layout

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScreenSize.isSmallScreen(context)
            ? _buildSmallScreenContent(context)
            : _buildLargeScreenContent(context),
      ),
    );
  }

  Widget _buildSmallScreenContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track and manage attendance efficiently',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildDashboardCards(context),
        const SizedBox(height: 24),
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildLargeScreenContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Track and manage attendance efficiently',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Online'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildDashboardCards(context),
        const SizedBox(height: 32),
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'admin@example.com',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.home,
            'Dashboard',
            () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.school,
            'Take Attendance',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/attendance');
            },
          ),
          _buildDrawerItem(
            context,
            Icons.sync,
            'Sync Status',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sync-status');
            },
          ),
          _buildDrawerItem(
            context,
            Icons.history,
            'Attendance History',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/attendance-history');
            },
          ),
          _buildDrawerItem(
            context,
            Icons.settings,
            'Settings',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildDashboardCards(BuildContext context) {
    return SizedBox(
      height: ScreenSize.isSmallScreen(context) ? 120 : 140,
      child: ScreenSize.isSmallScreen(context)
          ? Column(
              children: [
                _buildDashboardCard(
                  context,
                  'Total Students',
                  '245',
                  Icons.people,
                  Colors.blue.shade100,
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  context,
                  'Today\'s Attendance',
                  '220',
                  Icons.check_circle,
                  Colors.green.shade100,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    'Total Students',
                    '245',
                    Icons.people,
                    Colors.blue.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    context,
                    'Today\'s Attendance',
                    '220',
                    Icons.check_circle,
                    Colors.green.shade100,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.blue),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: ScreenSize.isSmallScreen(context) ? 100 : 120,
      child: ScreenSize.isSmallScreen(context)
          ? Column(
              children: [
                _buildQuickActionCard(
                  context,
                  'Take Attendance',
                  Icons.school,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/attendance');
                  },
                ),
                const SizedBox(height: 16),
                _buildQuickActionCard(
                  context,
                  'View Reports',
                  Icons.bar_chart,
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, '/attendance-summary');
                  },
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Take Attendance',
                    Icons.school,
                    Colors.blue,
                    () {
                      Navigator.pushNamed(context, '/attendance');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'View Reports',
                    Icons.bar_chart,
                    Colors.green,
                    () {
                      Navigator.pushNamed(context, '/attendance-summary');
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}