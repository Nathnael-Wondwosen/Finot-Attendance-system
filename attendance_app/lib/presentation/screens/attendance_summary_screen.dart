import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../providers/app_provider.dart';

class AttendanceSummaryScreen extends ConsumerStatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  ConsumerState<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState
    extends ConsumerState<AttendanceSummaryScreen> {
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
      final attendanceRepository = ref.read(attendanceRepositoryProvider);

      final classes = await classRepository.getClasses();
      final students = await studentRepository.getStudents();

      // Load real attendance records from database
      final allAttendance =
          await attendanceRepository
              .getAllAttendance(); // Get all attendance records

      // Group attendance by class and date to create summary records
      final groupedMap = <String, List<AttendanceEntity>>{};
      for (final attendance in allAttendance) {
        if (attendance.date != null && attendance.className != null) {
          // Parse the date string to get just the date part (YYYY-MM-DD)
          DateTime attendanceDate;
          try {
            attendanceDate = DateTime.parse(attendance.date!);
          } catch (e) {
            // If parsing fails, skip this record
            continue;
          }

          final key =
              '${attendance.className}_${attendanceDate.year}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}';
          if (!groupedMap.containsKey(key)) {
            groupedMap[key] = [];
          }
          groupedMap[key]!.add(attendance);
        }
      }

      // Convert grouped attendance to summary records
      final records = <AttendanceRecord>[];
      for (final entry in groupedMap.entries) {
        final parts = entry.key.split('_');
        if (parts.length < 2) continue; // Skip if the key format is incorrect

        final className = parts[0];
        final dateStr = parts
            .sublist(1)
            .join(
              '_',
            ); // Join the remaining parts in case the class name has underscores

        int presentCount = 0;
        int absentCount = 0;
        int lateCount = 0;

        for (final attendance in entry.value) {
          switch (attendance.status) {
            case 'present':
              presentCount++;
              break;
            case 'absent':
              absentCount++;
              break;
            case 'late':
              lateCount++;
              break;
          }
        }

        // Parse the date from the key (format: YYYY-MM-DD)
        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(dateStr);
        } catch (e) {
          // If parsing fails, use today's date as fallback
          parsedDate = DateTime.now();
        }

        records.add(
          AttendanceRecord(
            id: records.length + 1,
            className: className,
            date: parsedDate,
            presentCount: presentCount,
            absentCount: absentCount,
            lateCount: lateCount,
          ),
        );
      }

      setState(() {
        _classes = classes;
        _students = students;
        _attendanceRecords = records;
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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceRecords.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
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
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
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
                                builder:
                                    (context) => DetailedAttendanceScreen(
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
class DetailedAttendanceScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Get students for the specific class
    final classEntity = classes.firstWhere(
      (c) => c.name == record.className,
      orElse: () => classes.first,
    );

    final classStudents =
        students.where((s) => s.classId == classEntity.serverId).toList();

    // Load real attendance records for this specific class and date
    final attendanceRepository = ref.read(attendanceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Details - ${record.className}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<AttendanceEntity>>(
        future: attendanceRepository.getAttendanceByClassSectionDate(
          classEntity.serverId ?? 0,
          0,
          record.date.toIso8601String(),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading attendance: ${snapshot.error}'),
            );
          }

          final attendanceRecords = snapshot.data ?? [];

          // Create attendance details from real attendance records
          final attendanceDetails = <AttendanceDetail>[];

          for (final attendance in attendanceRecords) {
            // Find the corresponding student
            final student = classStudents.firstWhere(
              (s) => s.id == attendance.studentId,
              orElse:
                  () => StudentEntity(
                    id: attendance.studentId,
                    name: 'Unknown Student',
                    classId: attendance.classId,
                    sectionId: 0,
                  ),
            );

            attendanceDetails.add(
              AttendanceDetail(student: student, status: attendance.status),
            );
          }

          return Padding(
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
                          _buildStatusSummary(
                            'Present',
                            record.presentCount,
                            Colors.green,
                          ),
                          _buildStatusSummary(
                            'Absent',
                            record.absentCount,
                            Colors.red,
                          ),
                          _buildStatusSummary(
                            'Late',
                            record.lateCount,
                            Colors.orange,
                          ),
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
                                detail.student.fullName
                                    .substring(0, 1)
                                    .toUpperCase(),
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
          );
        },
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
        Text(label, style: TextStyle(color: color, fontSize: 12)),
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

  AttendanceDetail({required this.student, required this.status});
}
