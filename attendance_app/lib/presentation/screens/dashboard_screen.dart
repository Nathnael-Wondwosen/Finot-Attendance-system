import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/responsive_layout.dart';

// Futuristic dashboard UI with gradients, glass cards, and responsive layout
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ScreenSize.isSmallScreen(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: colorScheme.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          _buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: 'Attendance Overview',
                    action: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onBackground.withOpacity(0.7),
                      ),
                      child: const Text('View all'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDashboardCards(context, isMobile),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Quick Actions',
                    action: TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onBackground.withOpacity(0.7),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Smart suggestions'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuickActions(context, isMobile),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Activity Timeline',
                    action: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onBackground.withOpacity(0.7),
                      ),
                      child: const Text('Export'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRecentActivity(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade800.withOpacity(0.3),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'admin@example.com',
                  style: TextStyle(
                    fontSize: 12,
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
            () => Navigator.pop(context),
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onBackground.withOpacity(0.75)),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onBackground),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDashboardCards(BuildContext context, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildDashboardCard(
                context,
                title: 'Total Students',
                value: '245',
                trend: '+12 this week',
                icon: Icons.people_alt_rounded,
                colors: [const Color(0xFF6DD5FA), const Color(0xFF2980B9)],
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildDashboardCard(
                context,
                title: 'Today\'s Attendance',
                value: '220',
                trend: '92% present',
                icon: Icons.verified_rounded,
                colors: [const Color(0xFF7F00FF), const Color(0xFFE100FF)],
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildDashboardCard(
                context,
                title: 'Average Check-in',
                value: '08:07 AM',
                trend: '3 mins faster',
                icon: Icons.timelapse_rounded,
                colors: [const Color(0xFF00B09B), const Color(0xFF96C93D)],
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildDashboardCard(
                context,
                title: 'Sync Health',
                value: '99.2%',
                trend: 'All nodes online',
                icon: Icons.cloud_sync_rounded,
                colors: [const Color(0xFF1FA2FF), const Color(0xFF12D8FA)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              StatusChip(
                text: 'Live',
                color: Colors.white,
                textColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                trend,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - 18) / 3;

        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildQuickActionCard(
                context,
                title: 'Take Attendance',
                subtitle: 'Scan, mark, and sync',
                icon: Icons.auto_graph_rounded,
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/attendance'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildQuickActionCard(
                context,
                title: 'View Reports',
                subtitle: 'Insights & exports',
                icon: Icons.dashboard_customize_rounded,
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/attendance-summary'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildQuickActionCard(
                context,
                title: 'Sync Status',
                subtitle: 'Nodes & uptime',
                icon: Icons.cloud_sync_outlined,
                color: Colors.deepPurple,
                onTap: () => Navigator.pushNamed(context, '/sync-status'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildQuickActionCard(
                context,
                title: 'Settings',
                subtitle: 'Security & roles',
                icon: Icons.tune_rounded,
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.14),
                  border: Border.all(color: color.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      children: [
        _buildActivityItem(
          'Mathematics Class',
          '20 students marked present',
          '2 hours ago',
          Icons.school,
          Colors.blue,
        ),
        _buildActivityItem(
          'Science Class',
          '18 students marked present',
          '4 hours ago',
          Icons.school,
          Colors.green,
        ),
        _buildActivityItem(
          'Sync completed',
          'Attendance data synced to server',
          'Yesterday',
          Icons.sync,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.28), Colors.white.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    'Synced',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.background;
    final accent = scheme.primary.withOpacity(0.12);
    final accentAlt = scheme.primaryContainer.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            base,
            Color.lerp(base, accent, 0.6)!,
            Color.lerp(base, accentAlt, 0.8)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _BlurCircle(
              size: 220,
              color: scheme.primary.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _BlurCircle(
              size: 200,
              color: scheme.secondary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}
