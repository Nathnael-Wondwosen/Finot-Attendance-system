import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive_layout.dart';
import '../../core/ui_components.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';
import 'class_selection_screen.dart';
import 'attendance_summary_screen.dart';
import 'sync_status_screen.dart';
import 'settings_screen.dart';
import 'sidebar_drawer.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? arguments;

  const AttendanceScreen({super.key, this.arguments});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  List<StudentEntity> _students = [];
  List<StudentEntity> _filteredStudents = [];
  List<ClassEntity> _classes = [];
  final Map<int?, String> _attendanceStatus = {};
  bool _isLoading = true;
  bool _isLoadingClasses = true;
  bool _isSyncingSelected = false;
  String _selectedClassId = '';
  String _selectedClassName = '';
  DateTime _selectedDate = DateTime.now();
  String _statusFilter = 'all'; // all | present | absent | late

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      _selectedClassId = widget.arguments!['classId'] ?? '';
      _selectedClassName = widget.arguments!['className'] ?? '';
    }

    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    try {
      final classRepo = ref.read(classRepositoryProvider);
      final classes = await classRepo.getClasses();
      setState(() {
        _classes = classes;
        _isLoadingClasses = false;
      });

      // Auto-select class: priority to passed args, else first cached
      if (_selectedClassId.isEmpty && classes.isNotEmpty) {
        final first = classes.first;
        _selectedClassId = (first.serverId ?? first.id ?? '').toString();
        _selectedClassName = first.name;
      }

      if (_selectedClassId.isEmpty) {
        _isLoading = false;
        _showBanner('No classes found. Download classes first.', Colors.orange);
      } else {
        await _loadStudents();
      }
    } catch (e) {
      setState(() => _isLoadingClasses = false);
      _showBanner('Error loading classes: $e', Colors.red);
    }
  }

  /// Sync a single class then refresh local data
  Future<void> _downloadClass({
    required int classId,
    required String className,
    bool openAfter = false,
  }) async {
    if (classId == 0) return;
    setState(() => _isSyncingSelected = true);
    try {
      final syncService = ref.read(syncServiceProvider);
      final success = await syncService.downloadClassData(classId.toString());
      if (success) {
        await _loadClasses();
        await _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synced $className successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        _showBanner('Failed to sync $className', Colors.red);
      }
    } catch (e) {
      _showBanner('Error syncing class: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSyncingSelected = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClassId.isEmpty) {
      setState(() => _isLoading = false);
      _showBanner('Select a class to take attendance.', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentRepository = ref.read(studentRepositoryProvider);
      // Get students for the selected class - convert string to int
      final classId = int.tryParse(_selectedClassId) ?? 0;

      // First, let's check if there are any students in the database at all
      final allStudents = await studentRepository.getStudents();
      print('Total students in database: ${allStudents.length}');

      // Then get students for the specific class
      final students = await studentRepository.getStudentsByClass(classId);
      print('Students for class $_selectedClassId: ${students.length}');

      setState(() {
        _students = students;
        _filteredStudents = students; // Initialize filtered list
        // Initialize all students as present by default
        for (var student in _students) {
          _attendanceStatus[student.id] = 'present';
        }
        _isLoading = false;
      });

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No students found for this class. Make sure to download class data first.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading students: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleAttendance(int? studentId) {
    if (studentId == null) return;

    setState(() {
      if (_attendanceStatus[studentId] == 'present') {
        _attendanceStatus[studentId] = 'absent';
      } else if (_attendanceStatus[studentId] == 'absent') {
        _attendanceStatus[studentId] = 'late';
      } else {
        _attendanceStatus[studentId] = 'present';
      }
    });
  }

  Future<void> _openClassSelector() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClassSelectionScreen()),
    );
    // After returning, reload classes and students to reflect any selection made
    await _loadClasses();
  }

  void _setAttendance(int? studentId, String status) {
    if (studentId == null) return;
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _searchStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents =
            _students
                .where(
                  (student) => student.fullName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  List<StudentEntity> _applyStatusFilter(List<StudentEntity> list) {
    if (_statusFilter == 'all') return list;
    return list
        .where((s) => (_attendanceStatus[s.id] ?? 'present') == _statusFilter)
        .toList();
  }

  void _markAll(String status) {
    setState(() {
      for (final s in _filteredStudents) {
        _attendanceStatus[s.id] = status;
      }
      _statusFilter = status == 'all' ? 'all' : _statusFilter;
    });
  }

  void _showBanner(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      default:
        return 'Present';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Future<void> _saveAttendance() async {
    final presentCount =
        _attendanceStatus.values.where((status) => status == 'present').length;
    final absentCount =
        _attendanceStatus.values.where((status) => status == 'absent').length;
    final lateCount =
        _attendanceStatus.values.where((status) => status == 'late').length;

    // Save attendance records to the database
    final attendanceRepository = ref.read(attendanceRepositoryProvider);

    for (final entry in _attendanceStatus.entries) {
      final studentId = entry.key;
      final status = entry.value;

      final attendanceEntity = AttendanceEntity(
        studentId: studentId ?? 0,
        classId: int.tryParse(_selectedClassId) ?? 0,
        className: _selectedClassName,
        status: status,
        date: _selectedDate.toIso8601String(),
        synced: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await attendanceRepository.saveAttendance(attendanceEntity);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance saved for ${_selectedDate.toString().split(' ')[0]}! '
          'Present: $presentCount, Absent: $absentCount, Late: $lateCount',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Keep user in context and offer quick next steps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.successColor,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Saved for ${_selectedDate.toString().split(' ')[0]} — Present: $presentCount, Absent: $absentCount, Late: $lateCount',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceSummaryScreen(),
                  ),
                );
              },
              child: const Text(
                'View summary',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarScaffold(
      title:
          'Attendance - ${_selectedClassName.isEmpty ? 'Select Class' : _selectedClassName}',
      navigationItems: [
        const NavigationItem(title: 'Dashboard', icon: Icons.dashboard),
        const NavigationItem(title: 'Classes', icon: Icons.school),
        const NavigationItem(title: 'Summary', icon: Icons.summarize),
        const NavigationItem(title: 'Sync', icon: Icons.sync),
        const NavigationItem(title: 'Settings', icon: Icons.settings),
      ],
      currentIndex: 2, // Attendance tab
      onNavigationChanged: (index) {
        _handleNavigation(context, index);
      },
      child: Column(
        children: [
          // Header with clear instructions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: CustomCard(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryColor.withOpacity(0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Take Attendance',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppTheme.textColorPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a class, mark statuses, and save without leaving the screen.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Class selection
                  Row(
                    children: [
                      Expanded(
                        child: _isLoadingClasses
                            ? const LinearProgressIndicator(minHeight: 3)
                            : DropdownButtonFormField<String>(
                              value:
                                  _selectedClassId.isEmpty
                                      ? null
                                      : _selectedClassId,
                              items:
                                  _classes
                                      .map(
                                        (cls) => DropdownMenuItem<String>(
                                          value:
                                              (cls.serverId ?? cls.id ?? '')
                                                  .toString(),
                                          child: Text(
                                            cls.name,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              decoration: InputDecoration(
                                labelText: 'Select class',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusLg),
                                  borderSide: BorderSide(
                                    color: AppTheme.neutralDark,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              dropdownColor: Colors.white,
                              onChanged: (val) async {
                                if (val == null) return;
                                setState(() {
                                  _selectedClassId = val;
                                  _selectedClassName =
                                      _classes
                                          .firstWhere(
                                            (c) =>
                                                (c.serverId ?? c.id ?? '')
                                                    .toString() ==
                                                val,
                                          )
                                          .name;
                                });
                                await _loadStudents();
                              },
                            ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Sync selected',
                        onPressed:
                            _isSyncingSelected || _selectedClassId.isEmpty
                                ? null
                                : () async {
                                  final selected = _selectedClassId;
                                  if (selected.isNotEmpty) {
                                    await _downloadClass(
                                      classId: int.tryParse(selected) ?? 0,
                                      className: _selectedClassName,
                                      openAfter: false,
                                    );
                                  }
                                },
                        icon:
                            _isSyncingSelected
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                : const Icon(Icons.sync),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Class list'),
                        onPressed: _openClassSelector,
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload'),
                        onPressed: () async {
                          await _loadClasses();
                          if (_selectedClassId.isNotEmpty) {
                            await _loadStudents();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: ScreenSize.isSmallScreen(context) ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: _selectDate,
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.cyanAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Change',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusChip('present', 'Present', Colors.green),
                    _buildStatusChip('absent', 'Absent', Colors.red),
                    _buildStatusChip('late', 'Late', Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCount('present', Colors.green),
                    _buildStatusCount('absent', Colors.red),
                    _buildStatusCount('late', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                ),
              ),
              onChanged: _searchStudents,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  active: _statusFilter == 'all',
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Present',
                  active: _statusFilter == 'present',
                  color: Colors.green,
                  onTap: () => setState(() => _statusFilter = 'present'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Absent',
                  active: _statusFilter == 'absent',
                  color: Colors.red,
                  onTap: () => setState(() => _statusFilter = 'absent'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Late',
                  active: _statusFilter == 'late',
                  color: Colors.orange,
                  onTap: () => setState(() => _statusFilter = 'late'),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.flash_on,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'present_all') _markAll('present');
                    if (value == 'absent_all') _markAll('absent');
                    if (value == 'late_all') _markAll('late');
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'present_all',
                          child: Text('Mark all Present'),
                        ),
                        const PopupMenuItem(
                          value: 'absent_all',
                          child: Text('Mark all Absent'),
                        ),
                        const PopupMenuItem(
                          value: 'late_all',
                          child: Text('Mark all Late'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredStudents.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 72,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedClassId.isEmpty
                                ? 'Please select a class first'
                                : 'No students in this class yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedClassId.isEmpty
                                ? 'Choose a class from the dropdown above to see students'
                                : 'Download or sync the class roster to start attendance.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedClassId.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _loadStudents,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadStudents,
                      child: ListView.builder(
                        itemCount: _applyStatusFilter(_filteredStudents).length,
                        itemBuilder: (context, index) {
                          final visibleStudents = _applyStatusFilter(
                            _filteredStudents,
                          );
                          final student = visibleStudents[index];
                          final status =
                              _attendanceStatus[student.id] ?? 'present';

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getStatusColor(
                                          status,
                                        ).withOpacity(0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.fullName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        student.actualGrade ??
                                            'Grade not specified',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _StatusPill(
                                  label: _getStatusText(status),
                                  color: _getStatusColor(status),
                                  onTap:
                                      () => _showStudentAttendanceDetails(
                                        student,
                                      ),
                                ),
                                const SizedBox(width: 10),
                                _MiniToggle(
                                  current: status,
                                  onSelect:
                                      (s) => _setAttendance(student.id, s),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveAttendance,
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text(
                    'Save Attendance',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label, Color color) {
    final count = _attendanceStatus.values.where((s) => s == status).length;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusCount(String status, Color color) {
    final count = _attendanceStatus.values.where((s) => s == status).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(StudentEntity student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student.fullName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Grade: ${student.actualGrade ?? 'Not specified'}'),
              const SizedBox(height: 8),
              if (student.phoneNumber != null)
                Text('Phone: ${student.phoneNumber}'),
              if (student.fatherPhone != null)
                Text('Father: ${student.fatherPhone}'),
              if (student.motherPhone != null)
                Text('Mother: ${student.motherPhone}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showStudentAttendanceDetails(StudentEntity student) {
    final status = _attendanceStatus[student.id] ?? 'present';
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _getStatusColor(status).withOpacity(0.18),
                    child: Text(
                      student.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          student.actualGrade ?? 'Grade not specified',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.6),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Attendance for ${_selectedDate.toString().split(' ')[0]}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusPill(
                    label: 'Present',
                    color: Colors.green,
                    onTap: () => _setAttendance(student.id, 'present'),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Absent',
                    color: Colors.red,
                    onTap: () => _setAttendance(student.id, 'absent'),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'Late',
                    color: Colors.orange,
                    onTap: () => _setAttendance(student.id, 'late'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _StatusSummaryRow(attendanceStatus: _attendanceStatus),
              const SizedBox(height: 8),
              Text(
                'Tap a status to update. Changes save when you close.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Trigger rebuild so list reflects any changes made in sheet
      setState(() {});
    });
  }

  void _handleNavigation(BuildContext context, int index) {
    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClassSelectionScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AttendanceSummaryScreen(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SyncStatusScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _MiniToggle({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('present', Icons.check_circle, Colors.green),
      ('absent', Icons.cancel, Colors.red),
      ('late', Icons.schedule, Colors.orange),
    ];

    return Wrap(
      spacing: 6,
      children:
          options.map((o) {
            final active = current == o.$1;
            return GestureDetector(
              onTap: () => onSelect(o.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      active
                          ? o.$3.withOpacity(0.16)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        active
                            ? o.$3.withOpacity(0.55)
                            : Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Icon(
                  o.$2,
                  size: 16,
                  color:
                      active
                          ? o.$3
                          : Theme.of(context).iconTheme.color?.withOpacity(0.7),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              active
                  ? accent.withOpacity(0.18)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                active
                    ? accent.withOpacity(0.6)
                    : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? accent : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StatusSummaryRow extends StatelessWidget {
  final Map<int?, String> attendanceStatus;

  const _StatusSummaryRow({required this.attendanceStatus});

  int _count(String status) =>
      attendanceStatus.values.where((s) => s == status).length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('Present', _count('present'), Colors.green),
        const SizedBox(width: 8),
        _pill('Absent', _count('absent'), Colors.red),
        const SizedBox(width: 8),
        _pill('Late', _count('late'), Colors.orange),
      ],
    );
  }

  Widget _pill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
