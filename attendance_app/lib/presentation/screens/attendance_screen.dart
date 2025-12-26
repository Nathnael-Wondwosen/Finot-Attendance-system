import 'package:flutter/material.dart';

// Sample student data - in real app this would come from repository
final List<Map<String, dynamic>> _students = [
  {'id': 1, 'name': 'John Doe', 'rollNumber': '001'},
  {'id': 2, 'name': 'Jane Smith', 'rollNumber': '002'},
  {'id': 3, 'name': 'Robert Johnson', 'rollNumber': '003'},
  {'id': 4, 'name': 'Emily Davis', 'rollNumber': '004'},
  {'id': 5, 'name': 'Michael Wilson', 'rollNumber': '005'},
  {'id': 6, 'name': 'Sarah Brown', 'rollNumber': '006'},
  {'id': 7, 'name': 'David Taylor', 'rollNumber': '007'},
  {'id': 8, 'name': 'Lisa Anderson', 'rollNumber': '008'},
];

class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Map to store attendance status for each student
  final Map<int, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    // Initialize all students as present by default
    for (var student in _students) {
      _attendanceStatus[student['id']] = 'present';
    }
  }

  void _toggleAttendance(int studentId) {
    setState(() {
      if (_attendanceStatus[studentId] == 'present') {
        _attendanceStatus[studentId] = 'absent';
      } else {
        _attendanceStatus[studentId] = 'present';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save attendance logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance saved locally!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip('present', 'Present', Colors.green),
                _buildStatusChip('absent', 'Absent', Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final status = _attendanceStatus[student['id']] ?? 'present';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(student['name'][0]),
                    ),
                    title: Text(student['name']),
                    subtitle: Text('Roll No: ${student['rollNumber']}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'present' ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status == 'present' ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: status == 'present' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => _toggleAttendance(student['id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to summary
          Navigator.of(context).pop(); // For now, just go back
        },
        label: const Text('Save & Continue'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildStatusChip(String status, String label, Color color) {
    final count = _attendanceStatus.values.where((s) => s == status).length;
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}