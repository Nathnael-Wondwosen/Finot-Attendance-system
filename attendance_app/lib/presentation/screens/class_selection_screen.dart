import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'attendance_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  @override
  State<ClassSelectionScreen> createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  // Sample data - in real app this would come from repository
  final List<Map<String, dynamic>> _classes = [
    {'id': 1, 'name': 'Grade 1'},
    {'id': 2, 'name': 'Grade 2'},
    {'id': 3, 'name': 'Grade 3'},
    {'id': 4, 'name': 'Grade 4'},
    {'id': 5, 'name': 'Grade 5'},
  ];

  final List<Map<String, dynamic>> _sections = [
    {'id': 1, 'name': 'Section A', 'classId': 1},
    {'id': 2, 'name': 'Section B', 'classId': 1},
    {'id': 3, 'name': 'Section A', 'classId': 2},
    {'id': 4, 'name': 'Section B', 'classId': 2},
  ];

  int? _selectedClassId;
  int? _selectedSectionId;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class & Section'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _classes.length,
                itemBuilder: (context, classIndex) {
                  final classItem = _classes[classIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(
                        classItem['name'],
                        style: TextStyle(
                          fontWeight: _selectedClassId == classItem['id']
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      leading: _selectedClassId == classItem['id']
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                      children: [
                        ..._sections
                            .where((section) => section['classId'] == classItem['id'])
                            .map((section) => RadioListTile<int>(
                                  title: Text(section['name']),
                                  value: section['id'],
                                  groupValue: _selectedSectionId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClassId = classItem['id'];
                                      _selectedSectionId = value;
                                    });
                                  },
                                ))
                            .toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedSectionId != null
            ? () {
                // Navigate to attendance screen with selected data
                Navigator.of(context).pushNamed(
                  Routes.attendance,
                );
              }
            : null,
        label: const Text('Continue'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}