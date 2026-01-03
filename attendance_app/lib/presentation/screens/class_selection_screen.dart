import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/app_provider.dart';
import 'attendance_screen.dart';

/// ===============================
/// VIEW MODE ENUM
/// ===============================
enum ClassViewMode { compact, comfortable, grid }

/// ===============================
/// CLASS SELECTION SCREEN
/// ===============================
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

  /// ===============================
  /// DATA LOADING
  /// ===============================
  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(classRepositoryProvider);
      final classes = await repo.getClasses();

      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading classes');
    }
  }

  Future<void> _loadDownloadedClasses() async {
    try {
      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents();

      final ids = <int>{};
      for (final s in students) {
        if (s.classId > 0) ids.add(s.classId);
      }

      setState(() => _downloadedClassIds = ids.toList());
    } catch (_) {}
  }

  bool _isClassDownloaded(int? id) =>
      id != null && _downloadedClassIds.contains(id);

  /// ===============================
  /// DOWNLOAD + NAVIGATE
  /// ===============================
  Future<void> _downloadAndShowClassData(ClassEntity cls) async {
    try {
      setState(() => _isLoading = true);

      final syncService = ref.read(syncServiceProvider);
      final ok = await syncService.downloadClassData(cls.serverId.toString());

      if (!ok) throw Exception('Download failed');

      await _loadDownloadedClasses();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ClassStudentsScreen(
                classId: cls.serverId.toString(),
                className: cls.name,
              ),
        ),
      );
    } catch (_) {
      _showError('Failed to download class data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_classes.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadClasses();
        await _loadDownloadedClasses();
      },
      child: _buildClassContent(),
    );
  }

  Widget _buildClassContent() {
    switch (_viewMode) {
      case ClassViewMode.grid:
        return _buildGridView();
      case ClassViewMode.comfortable:
        return _buildListView(dense: false);
      case ClassViewMode.compact:
        return _buildListView(dense: true);
    }
  }

  /// ===============================
  /// LIST VIEW (COMPACT / COMFORT)
  /// ===============================
  Widget _buildListView({required bool dense}) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _classes.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (_, i) {
        final cls = _classes[i];
        final downloaded = _isClassDownloaded(cls.serverId);

        return InkWell(
          onTap: () => _downloadAndShowClassData(cls),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.symmetric(
              vertical: dense ? 8 : 12,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: downloaded ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        downloaded ? 'Offline available' : 'Online only',
                        style: TextStyle(
                          fontSize: 11,
                          color: downloaded ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  downloaded
                      ? Icons.download_done
                      : Icons.cloud_download_outlined,
                  size: 16,
                  color: downloaded ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ===============================
  /// RESPONSIVE GRID VIEW (SAFE)
  /// ===============================
  Widget _buildGridView() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount =
        width > 900
            ? 4
            : width > 600
            ? 3
            : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _classes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemBuilder: (_, i) {
        final cls = _classes[i];
        final downloaded = _isClassDownloaded(cls.serverId);

        return InkWell(
          onTap: () => _downloadAndShowClassData(cls),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.class_,
                      size: 18,
                      color: downloaded ? Colors.cyanAccent : Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        cls.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: downloaded ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        downloaded ? 'Offline' : 'Online',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: downloaded ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    Icon(
                      downloaded
                          ? Icons.download_done
                          : Icons.cloud_download_outlined,
                      size: 16,
                      color: downloaded ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ===============================
/// EMPTY STATE
/// ===============================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
              ),
              child: Icon(Icons.class_, size: 30, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect to the internet and refresh',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// CLASS STUDENTS SCREEN
/// ===============================
class ClassStudentsScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const ClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<ClassStudentsScreen> createState() =>
      _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends ConsumerState<ClassStudentsScreen> {
  List<StudentEntity> _students = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<StudentEntity> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _filteredStudents = _students; // Initialize with all students
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudentsByClass(int.parse(widget.classId));

      setState(() {
        _students = students;
        _filteredStudents = students; // Also update filtered students
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<StudentEntity> _filterStudents() {
    if (_searchController.text.isEmpty) {
      return _students;
    }
    return _students.where((student) {
      return student.fullName.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update filtered students when search changes
    if (_searchController.text.isNotEmpty) {
      _filteredStudents = _filterStudents();
    } else {
      _filteredStudents = _students;
    }

    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search students...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search, color: Colors.cyanAccent),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Student list
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.search_off,
                              size: 30,
                              color: Colors.cyanAccent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStudents.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = _filteredStudents[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                s.fullName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.cyanAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            s.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            s.actualGrade ?? 'Grade not specified',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          onTap: () {
                            // Navigate to attendance screen for this student
                            HapticFeedback.lightImpact(); // Provide haptic feedback
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AttendanceScreen(
                                      arguments: {
                                        'classId': widget.classId,
                                        'className': widget.className,
                                      },
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
