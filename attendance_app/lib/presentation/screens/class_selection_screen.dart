import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../core/ui_components.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/app_provider.dart';
import 'attendance_screen.dart';
import 'sidebar_drawer.dart';
import 'dashboard_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';

/// ===============================
/// VIEW MODE ENUM
/// ===============================
enum ClassViewMode { compact, comfortable, grid }

/// Class Selection Screen - Minimalist Design
class ClassSelectionScreen extends ConsumerStatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  ConsumerState<ClassSelectionScreen> createState() =>
      _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends ConsumerState<ClassSelectionScreen> {
  List<ClassEntity> _classes = [];
  List<int> _downloadedClassIds = [];
  bool _isLoading = true;
  ClassViewMode _viewMode = ClassViewMode.compact;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadDownloadedClasses();
  }

  /// Data Loading
  Future<void> _loadClasses() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(classRepositoryProvider);
      final classes = await repo.getClasses();

      if (!mounted) return;
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error loading classes');
      }
    }
  }

  Future<void> _loadDownloadedClasses() async {
    if (!mounted) return;
    try {
      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents();

      final ids = <int>{};
      for (final s in students) {
        if (s.classId > 0) ids.add(s.classId);
      }

      if (mounted) {
        setState(() => _downloadedClassIds = ids.toList());
      }
    } catch (_) {}
  }

  bool _isClassDownloaded(int? id) =>
      id != null && _downloadedClassIds.contains(id);

  bool _isClassDownloading(int? id) =>
      id != null && (_downloadingByClass[id] ?? false);

  /// Download and Navigate
  Future<void> _downloadAndShowClassData(ClassEntity cls) async {
    final classId = cls.serverId ?? cls.id ?? 0;
    if (classId == 0) {
      _showError('Invalid class id');
      return;
    }
    await _downloadClass(
      classId: classId,
      className: cls.name,
      openAfter: true,
    );
  }

  Future<void> _downloadClass({
    required int classId,
    required String className,
    bool openAfter = false,
  }) async {
    if (classId == 0 || !mounted) return;

    setState(() {
      _downloadingByClass[classId] = true;
    });

    try {
      final syncService = ref.read(syncServiceProvider);
      final success = await syncService.downloadClassData(classId.toString());

      if (!mounted) return;

      if (success) {
        await _loadDownloadedClasses();

        if (openAfter && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AttendanceScreen(
                    arguments: {
                      'classId': classId.toString(),
                      'className': className,
                    },
                  ),
            ),
          );
        }
      } else {
        if (mounted) _showError('Failed to download class data');
      }
    } catch (e) {
      if (mounted) _showError('Error downloading class: $e');
    } finally {
      if (mounted) {
        setState(() {
          _downloadingByClass[classId] = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  final Map<int, bool> _downloadingByClass = {};

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title: 'Classes',
      navigationItems: const [
        NavigationItem(title: 'Dashboard', icon: Icons.dashboard),
        NavigationItem(title: 'Classes', icon: Icons.school),
        NavigationItem(title: 'Summary', icon: Icons.summarize),
        NavigationItem(title: 'Sync', icon: Icons.sync),
        NavigationItem(title: 'Settings', icon: Icons.settings),
      ],
      currentIndex: 1, // Classes tab
      onNavigationChanged: (index) {
        _handleNavigation(context, index);
      },
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _classes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 60,
                      color: AppTheme.textColorSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No classes found',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download classes from server',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                  ],
                ),
              )
              : _buildClassList(),
    );
  }

  Widget _buildClassList() {
    switch (_viewMode) {
      case ClassViewMode.compact:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _classes.length,
          itemBuilder: (context, index) {
            final cls = _classes[index];
            return _buildClassCard(cls, index);
          },
        );
      case ClassViewMode.comfortable:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _classes.length,
          itemBuilder: (context, index) {
            final cls = _classes[index];
            return _buildClassCard(cls, index);
          },
        );
      case ClassViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _classes.length,
          itemBuilder: (context, index) {
            final cls = _classes[index];
            return _buildClassCard(cls, index);
          },
        );
    }
  }

  Widget _buildClassCard(ClassEntity cls, int index) {
    final isDownloaded = _isClassDownloaded(cls.serverId);
    final isDownloading = _isClassDownloading(cls.serverId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.neutralMedium, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.school, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          cls.name,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textColorPrimary,
          ),
        ),
        subtitle: Text(
          'ID: ${cls.serverId ?? cls.id}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textColorSecondary,
          ),
        ),
        trailing:
            isDownloading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : isDownloaded
                ? Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 24,
                )
                : null,
        onTap: () => _downloadAndShowClassData(cls),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (!Navigator.canPop(context)) return;

    switch (index) {
      case 0:
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
        break;
      case 1:
        // Current screen
        break;
      case 2:
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AttendanceSummaryScreen(),
            ),
          );
        }
        break;
      case 3:
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SyncStatusScreen()),
          );
        }
        break;
      case 4:
        if (Navigator.canPop(context)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
        break;
    }
  }
}
