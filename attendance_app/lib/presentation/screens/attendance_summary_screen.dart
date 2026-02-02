import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
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
  List<AttendanceEntity> _individualAttendanceRecords = [];
  bool _isLoading = true;
  bool _showIndividualRecords =
      false; // Toggle between grouped and individual view

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
      print('DEBUG: Total attendance records loaded: ${allAttendance.length}');

      // Print detailed debug info about all records
      for (int i = 0; i < allAttendance.length; i++) {
        final att = allAttendance[i];
        print(
          'DEBUG: Attendance ${i + 1} - Class: "${att.className}", Date: "${att.date}", Status: "${att.status}", ClassId: ${att.classId}, StudentId: ${att.studentId}',
        );
      }

      // Group attendance by class and date to create summary records
      final groupedMap = <String, List<AttendanceEntity>>{};
      print(
        'DEBUG: Starting to group ${allAttendance.length} attendance records',
      );

      for (final attendance in allAttendance) {
        if (attendance.className != null) {
          // Parse the date string to get just the date part (YYYY-MM-DD)
          DateTime attendanceDate;
          try {
            attendanceDate = DateTime.parse(attendance.date);
            // Format the date to YYYY-MM-DD to ensure consistency
            final dateStr =
                '${attendanceDate.year}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}';
            final key = '${attendance.className}_$dateStr';

            print(
              'DEBUG: Processing attendance - Class: ${attendance.className}, DateStr: $dateStr, Key: $key',
            );

            if (!groupedMap.containsKey(key)) {
              groupedMap[key] = [];
            }
            groupedMap[key]!.add(attendance);
          } catch (e) {
            // If parsing fails, skip this record
            print(
              'DEBUG: Error parsing date for attendance: ${attendance.date}, Error: $e',
            );
            continue;
          }
        } else {
          print(
            'DEBUG: Skipping attendance with null date or className - Date: ${attendance.date}, ClassName: ${attendance.className}',
          );
        }
      }

      print('DEBUG: Grouped into ${groupedMap.length} unique combinations');
      groupedMap.forEach((key, value) {
        print('DEBUG: Group $key has ${value.length} records');
      });

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
        int classId = 0; // Initialize with default value

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
          // Get the classId from the first attendance record
          if (classId == 0) {
            classId = attendance.classId;
          }
        }

        // The dateStr is already in the correct format from the key creation
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
            classId: classId,
            date: parsedDate,
            presentCount: presentCount,
            absentCount: absentCount,
            lateCount: lateCount,
          ),
        );
      }

      // Also store individual attendance records for detailed view
      setState(() {
        _classes = classes;
        _students = students;
        _attendanceRecords = records;
        _individualAttendanceRecords = allAttendance;
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
    final theme = Theme.of(context);
    return SoftGradientBackground(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showIndividualRecords
                ? _buildIndividualAttendanceView()
                : _attendanceRecords.isEmpty
                ? _EmptySummary(theme: theme)
                : RefreshIndicator(
                  onRefresh: _loadAttendanceData,
                  child: ListView.builder(
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.cardColor.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: theme.dividerColor.withOpacity(0.12),
                          ),
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${record.date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            record.className,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '${record.date.toString().split(' ')[0]} • ${record.presentCount + record.absentCount + record.lateCount} students',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatPill(
                                label: 'Present',
                                value: record.presentCount,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 6),
                              _StatPill(
                                label: 'Absent',
                                value: record.absentCount,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 6),
                              _StatPill(
                                label: 'Late',
                                value: record.lateCount,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          onTap: () {
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

  Widget _buildIndividualAttendanceView() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _loadAttendanceData,
      child: ListView.builder(
        itemCount: _individualAttendanceRecords.length,
        itemBuilder: (context, index) {
          final attendance = _individualAttendanceRecords[index];

          // Find student name
          final student = _students.firstWhere(
            (s) => s.id == attendance.studentId,
            orElse:
                () => StudentEntity(
                  id: attendance.studentId,
                  name: 'Unknown Student',
                  classId: attendance.classId,
                  sectionId: 0,
                ),
          );

          final statusColor = _getStatusColor(attendance.status);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: theme.cardColor.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    student.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                student.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${attendance.className ?? 'Unknown Class'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateTime.parse(attendance.date).toString().split(' ')[0]} at ${DateTime.parse(attendance.date).toString().split(' ')[1].substring(0, 5)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
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
                  attendance.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  final ThemeData theme;
  const _EmptySummary({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance records yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take attendance to see summaries here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for attendance records
class AttendanceRecord {
  final int id;
  final String className;
  final int classId; // Add classId to help with matching
  final DateTime date;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  AttendanceRecord({
    required this.id,
    required this.className,
    required this.classId,
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
    // Get students for the specific class using the classId from the record
    final classStudents =
        students.where((s) => s.classId == record.classId).toList();

    // Load real attendance records for this specific class and date
    final attendanceRepository = ref.read(attendanceRepositoryProvider);

    return FutureBuilder<List<AttendanceEntity>>(
      future: attendanceRepository.getAttendanceByClassSectionDate(
        record.classId,
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

        // Create a map of student attendance for quick lookup
        final Map<int?, String> studentAttendanceMap = {};
        for (final attendance in attendanceRecords) {
          studentAttendanceMap[attendance.studentId] = attendance.status;
        }

        // Create attendance details for all students in the class
        final attendanceDetails = <AttendanceDetail>[];

        // For each student in the class, show their attendance status
        // If no attendance record exists for a student, default to 'absent'
        for (final student in classStudents) {
          final status = studentAttendanceMap[student.id] ?? 'absent';
          attendanceDetails.add(
            AttendanceDetail(student: student, status: status),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${record.className} - ${record.date.toString().split(' ')[0]}',
            ),
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
          ),
        );
      },
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
