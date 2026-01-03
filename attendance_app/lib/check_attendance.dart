import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/datasources/local_data_source.dart';

void main() {
  runApp(ProviderScope(child: MaterialApp(home: CheckAttendanceScreen())));
}

class CheckAttendanceScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Attendance Records')),
      body: FutureBuilder(
        future: _checkAttendance(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return snapshot.data!;
        },
      ),
    );
  }

  Future<Widget> _checkAttendance(WidgetRef ref) async {
    try {
      final localDataSource = LocalDataSource();
      final attendanceRepo = AttendanceRepositoryImpl(localDataSource);

      // Get all attendance records
      final allAttendance = await attendanceRepo.getAllAttendance();

      return ListView(
        children: [
          ListTile(
            title: Text('Total Attendance Records: ${allAttendance.length}'),
            subtitle: Text('Check console for details'),
          ),
          ...allAttendance.asMap().entries.map((entry) {
            final index = entry.key;
            final attendance = entry.value;
            return ListTile(
              title: Text('Record ${index + 1}'),
              subtitle: Text(
                'Class: ${attendance.className}\n'
                'Date: ${attendance.date}\n'
                'Status: ${attendance.status}\n'
                'Student ID: ${attendance.studentId}\n'
                'Class ID: ${attendance.classId}',
              ),
            );
          }),
        ],
      );
    } catch (e) {
      return Center(child: Text('Error checking attendance: $e'));
    }
  }
}
