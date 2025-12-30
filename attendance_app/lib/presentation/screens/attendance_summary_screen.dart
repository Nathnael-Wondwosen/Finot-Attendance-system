import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/app_provider.dart';

class AttendanceSummaryScreen extends ConsumerStatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  ConsumerState<AttendanceSummaryScreen> createState() => _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends ConsumerState<AttendanceSummaryScreen> {
  List<ClassEntity> _classes = [];
  List<StudentEntity> _students = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load classes and students
      final classRepository = ref.read(classRepositoryProvider);
      final studentRepository = ref.read(studentRepositoryProvider);
      
      final classes = await classRepository.getClasses();
      final students = await studentRepository.getStudents();

      // For now, we'll create some sample attendance records
      // In a real implementation, these would come from a local database
      final sampleRecords = <AttendanceRecord>[
        AttendanceRecord(
          id: 1,
          className: '10ኛ ክፍል',
          date: DateTime.now(),
          presentCount: 25,
          absentCount: 3,
          lateCount: 2,
        ),
        AttendanceRecord(
          id: 2,
          className: '11ኛ ክፍል',
          date: DateTime.now().subtract(const Duration(days: 1)),
          presentCount: 22,
          absentCount: 5,
          lateCount: 1,
        ),
        AttendanceRecord(
          id: 3,
          className: '9ኛ ክፍል',
          date: DateTime.now().subtract(const Duration(days: 2)),
          presentCount: 20,
          absentCount: 4,
          lateCount: 0,
        ),
      ];

      setState(() {
        _classes = classes;
        _students = students;
        _attendanceRecords = sampleRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading attendance data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _attendanceRecords.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No attendance records found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take attendance to see records here',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAttendanceData,
                    child: ListView.builder(
                      itemCount: _attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${record.date.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              record.className,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${record.date.toString().split(' ')[0]} • ${record.presentCount + record.absentCount + record.lateCount} students',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${record.presentCount} Present',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${record.absentCount} Absent',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${record.lateCount} Late',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to detailed attendance view
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedAttendanceScreen(
                                    record: record,
                                    students: _students,
                                    classes: _classes,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

// Model class for attendance records
class AttendanceRecord {
  final int id;
  final String className;
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  AttendanceRecord({
    required this.id,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });
}

// Detailed attendance screen
class DetailedAttendanceScreen extends StatelessWidget {
  final AttendanceRecord record;
  final List<StudentEntity> students;
  final List<ClassEntity> classes;

  const DetailedAttendanceScreen({
    super.key,
    required this.record,
    required this.students,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    // For now, we'll create a sample list of students with their attendance status
    // In a real implementation, this would come from the actual attendance records
    final classEntity = classes.firstWhere(
      (c) => c.name == record.className,
      orElse: () => classes.first,
    );
    
    final classStudents = students.where((s) => s.classId == classEntity.serverId).toList();
    
    // Create sample attendance details
    final attendanceDetails = <AttendanceDetail>[];
    
    // Add present students
    for (int i = 0; i < record.presentCount && i < classStudents.length; i++) {
      attendanceDetails.add(AttendanceDetail(
        student: classStudents[i],
        status: 'present',
      ));
    }
    
    // Add absent students
    for (int i = 0; i < record.absentCount && (i + record.presentCount) < classStudents.length; i++) {
      attendanceDetails.add(AttendanceDetail(
        student: classStudents[record.presentCount + i],
        status: 'absent',
      ));
    }
    
    // Add late students
    for (int i = 0; i < record.lateCount && (i + record.presentCount + record.absentCount) < classStudents.length; i++) {
      attendanceDetails.add(AttendanceDetail(
        student: classStudents[record.presentCount + record.absentCount + i],
        status: 'late',
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details - ${record.className}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${record.date.toString().split(' ')[0]}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusSummary('Present', record.presentCount, Colors.green),
                      _buildStatusSummary('Absent', record.absentCount, Colors.red),
                      _buildStatusSummary('Late', record.lateCount, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Students (${attendanceDetails.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceDetails.length,
                itemBuilder: (context, index) {
                  final detail = attendanceDetails[index];
                  final statusColor = _getStatusColor(detail.status);
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            detail.student.fullName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        detail.student.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        detail.student.actualGrade ?? 'Grade not specified',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          detail.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
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
        return Colors.grey;
    }
  }
}

// Model class for attendance details
class AttendanceDetail {
  final StudentEntity student;
  final String status;

  AttendanceDetail({
    required this.student,
    required this.status,
  });
}