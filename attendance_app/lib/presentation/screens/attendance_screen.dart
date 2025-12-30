import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../providers/app_provider.dart';

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
  String _searchQuery = '';

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
      _searchQuery = query;
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

  void _markAll(String status) {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student.id] = status;
      }
    });
  }

  Future<void> _saveAttendance() async {
    final presentCount =
        _attendanceStatus.values.where((status) => status == 'present').length;
    final absentCount =
        _attendanceStatus.values.where((status) => status == 'absent').length;
    final lateCount =
        _attendanceStatus.values.where((status) => status == 'late').length;

    // In a real implementation, you would save this to a local database
    // For now, we'll just show a success message
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

    // Navigate back and then to the attendance summary tab
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Go back to the class students screen
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Go back to the main screen
      }
    }

    // Find the MainScreen in the widget tree and update its selected index
    final mainScaffold = Scaffold.of(context);
    if (mainScaffold != null) {
      // Show a message to inform the user to go to the attendance tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Attendance saved! Switching to Attendance Summary tab...',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Add a delay before switching to the attendance tab
        Future.delayed(const Duration(seconds: 2)).then((_) {
          // Since we can't directly access the MainScreen state from here,
          // we'll just show a message and let the user navigate manually
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please go to the Attendance tab to view the summary.',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedClassName.isNotEmpty
              ? 'Attendance: $_selectedClassName'
              : 'Attendance',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String result) {
              if (result == 'mark_all_present') {
                _markAll('present');
              } else if (result == 'mark_all_absent') {
                _markAll('absent');
              } else if (result == 'mark_all_late') {
                _markAll('late');
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'mark_all_present',
                    child: Text('Mark All Present'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'mark_all_absent',
                    child: Text('Mark All Absent'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'mark_all_late',
                    child: Text('Mark All Late'),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: ScreenSize.isSmallScreen(context) ? 12 : 16,
            ),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Text(
                  'Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusChip('present', 'Present', Colors.green),
                    _buildStatusChip('absent', 'Absent', Colors.red),
                    _buildStatusChip('late', 'Late', Colors.orange),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${_attendanceStatus.values.where((status) => status == 'present').length} Present',
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      '${_attendanceStatus.values.where((status) => status == 'absent').length} Absent',
                      style: const TextStyle(color: Colors.red),
                    ),
                    Text(
                      '${_attendanceStatus.values.where((status) => status == 'late').length} Late',
                      style: const TextStyle(color: Colors.orange),
                    ),
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
          const SizedBox(height: 16),
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

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    student.fullName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                student.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                student.actualGrade ?? 'Grade not specified',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _isLoading
                ? null
                : () {
                  _saveAttendance();
                },
        label: const Text('Save Attendance'),
        icon: const Icon(Icons.check),
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
}
