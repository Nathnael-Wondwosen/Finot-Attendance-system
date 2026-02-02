import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/typography.dart';
import '../../core/ui_components.dart';
import '../../core/theme.dart';
import '../../domain/entities/class_entity.dart';
import '../providers/app_provider.dart';
import 'class_selection_screen.dart';
import 'attendance_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ClassEntity> _classes = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  int _cachedClassCount = 0;
  int _cachedStudentCount = 0;
  int _pendingSync = 0;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;
    try {
      final classRepo = ref.read(classRepositoryProvider);
      final studentRepo = ref.read(studentRepositoryProvider);
      final syncService = ref.read(syncServiceProvider);
      final classes = await classRepo.getClasses();
      final students = await studentRepo.getStudents();
      final status = await syncService.getSyncStatus();
      if (!mounted) return;
      setState(() {
        _cachedClassCount = classes.length;
        _cachedStudentCount = students.length;
        _pendingSync = status['unsyncedCount'] ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _loadCachedClasses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final classRepository = ref.read(classRepositoryProvider);
      final classes = await classRepository.getClasses();
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading classes: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _refreshFromServer() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.downloadAllClasses();
      await _loadCachedClasses();
      await _loadSummary();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final paddingTop = mediaQuery.padding.top;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.surfaceSoft,
      drawerEdgeDragWidth: screenWidth * 0.18,
      drawer: _buildSidebar(),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            const SoftGradientBackground(enableBlobs: true, child: SizedBox()),
            Column(
              children: [
                _buildTopBar(paddingTop),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshFromServer,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 18),
                          _buildQuickActions(),
                          const SizedBox(height: 18),
                          _buildSimpleAnalyticsChart(),
                          const SizedBox(height: 18),
                          _buildClassesSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double paddingTop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, paddingTop + 8, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(color: AppTheme.neutralMedium, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neutralLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu,
                color: AppTheme.textColorPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.16),
                  AppTheme.secondaryColor.withOpacity(0.16),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: AppText.titleSmall('FA', color: AppTheme.textColorPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.titleMedium(
                'Finot Attendance',
                color: AppTheme.textColorPrimary,
              ),
              AppText.bodySmall(
                'Stay synced everywhere',
                color: AppTheme.textColorSecondary,
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: AppTheme.successColor, size: 16),
                const SizedBox(width: 6),
                AppText.bodySmall('Online', color: AppTheme.successColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.titleMedium(
                'Today\'s Snapshot',
                color: AppTheme.textColorPrimary,
              ),
              const Spacer(),
              Icon(Icons.speed, color: AppTheme.primaryColor, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.school,
                  title: 'Classes',
                  value: _cachedClassCount.toString(),
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Students',
                  value: _cachedStudentCount.toString(),
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sync,
                  title: 'Pending',
                  value: _pendingSync.toString(),
                  color: AppTheme.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.18),
                        child: AppText.titleSmall('FA', color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.titleSmall(
                            'Finot Attendance',
                            color: Colors.white,
                          ),
                          AppText.bodySmall(
                            'Always in sync',
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        AppText.bodySmall('Online', color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _sidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _sidebarItem(
                    icon: Icons.check_circle_outline,
                    label: 'Attendance',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: navigate to attendance
                    },
                  ),
                  _sidebarItem(
                    icon: Icons.analytics_outlined,
                    label: 'Reports',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: navigate to reports
                    },
                  ),
                  _sidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: navigate to settings
                    },
                  ),
                  const Divider(),
                  _sidebarItem(
                    icon: Icons.sync,
                    label: 'Sync now',
                    onTap: () {
                      Navigator.pop(context);
                      _refreshFromServer();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: AppText.bodyMedium(label, color: AppTheme.textColorPrimary),
      onTap: onTap,
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: AppTheme.textColorSecondary,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.16), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          AppText.titleSmall(value, color: AppTheme.textColorPrimary),
          const SizedBox(height: 4),
          AppText.bodySmall(title, color: AppTheme.textColorSecondary),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.titleMedium(
                'Quick Actions',
                color: AppTheme.textColorPrimary,
              ),
              const Spacer(),
              Icon(Icons.bolt, color: AppTheme.secondaryColor, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionCard(
                icon: Icons.checklist,
                title: 'Take Attendance',
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.refresh,
                title: 'Sync Data',
                onTap: _refreshFromServer,
              ),
              _buildActionCard(
                icon: Icons.analytics,
                title: 'Reports',
                onTap: () {},
              ),
              _buildActionCard(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient:
              isPrimary
                  ? LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.18),
                      AppTheme.secondaryColor.withOpacity(0.16),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isPrimary ? null : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color:
                isPrimary
                    ? AppTheme.primaryColor.withOpacity(0.35)
                    : AppTheme.neutralLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPrimary ? 0.10 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isPrimary
                        ? AppTheme.primaryColor.withOpacity(0.16)
                        : AppTheme.neutralMedium,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    isPrimary
                        ? AppTheme.primaryColor
                        : AppTheme.textColorSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            AppText.bodySmall(
              title,
              color:
                  isPrimary ? AppTheme.primaryColor : AppTheme.textColorPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleAnalyticsChart() {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleMedium(
            'Attendance Overview',
            color: AppTheme.textColorPrimary,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBarChartItem('Mon', 40, AppTheme.primaryColor),
                  _buildBarChartItem('Tue', 60, AppTheme.primaryColor),
                  _buildBarChartItem('Wed', 50, AppTheme.primaryColor),
                  _buildBarChartItem('Thu', 80, AppTheme.primaryColor),
                  _buildBarChartItem('Fri', 70, AppTheme.primaryColor),
                  _buildBarChartItem('Sat', 90, AppTheme.primaryColor),
                  _buildBarChartItem('Sun', 75, AppTheme.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(String day, int value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 16,
          height: (value / 100) * 100, // Scale to fit container
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textColorSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildClassesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.titleMedium(
                  'Recent Classes',
                  color: AppTheme.textColorPrimary,
                ),
                TextButton(
                  onPressed: () {},
                  child: AppText.bodySmall(
                    'View All',
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_classes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 60,
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    AppText.bodyMedium(
                      'No classes found',
                      color: AppTheme.textColorSecondary,
                    ),
                    const SizedBox(height: 8),
                    AppText.bodySmall(
                      'Add classes or sync from server',
                      color: AppTheme.textColorSecondary,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  _classes.length > 5
                      ? 5
                      : _classes.length, // Show only first 5
              separatorBuilder: (context, index) => CustomDivider(height: 0.5),
              itemBuilder: (context, index) {
                final classEntity = _classes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(
                      color: AppTheme.neutralMedium,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: AppText.bodyMedium(
                      classEntity.name,
                      color: AppTheme.textColorPrimary,
                    ),
                    subtitle: AppText.bodySmall(
                      'ID: ${classEntity.id ?? 'N/A'}',
                      color: AppTheme.textColorSecondary,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textColorSecondary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AttendanceScreen(
                                arguments: {
                                  'classId': classEntity.serverId.toString(),
                                  'className': classEntity.name,
                                },
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
