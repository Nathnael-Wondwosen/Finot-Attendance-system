import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
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
  final Map<int?, String> _attendanceStatus = {};
  bool _isLoading = true;
  String _selectedClassId = '';
  String _selectedClassName = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      _selectedClassId = widget.arguments!['classId'] ?? '';
      _selectedClassName = widget.arguments!['className'] ?? '';
    }

    // Check if class data was passed, if not show an error message
    if (_selectedClassId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a class first from the Classes tab'),
            backgroundColor: Colors.orange,
          ),
        );
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _loadStudents();
    }
  }

  Future<void> _loadStudents() async {
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

    // Wait a moment to show the success message, then navigate to the attendance summary tab
    await Future.delayed(const Duration(milliseconds: 1500));

    // Navigate back to the main screen and select the attendance tab
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Go back to the class students screen
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Go back to the main screen
      }
    }

    // After navigating back, show a message to guide the user to the attendance summary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Attendance saved successfully! Go to the Attendance tab to view the summary.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    });
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchStudents,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredStudents.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No students found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check your internet connection or download class data again',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadStudents,
                      child: ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final status =
                              _attendanceStatus[student.id] ?? 'present';

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    student.fullName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                student.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                student.actualGrade ?? 'Grade not specified',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              onTap: () => _toggleAttendance(student.id),
                              onLongPress: () {
                                // Additional action on long press if needed
                                _showStudentDetails(student);
                              },
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
