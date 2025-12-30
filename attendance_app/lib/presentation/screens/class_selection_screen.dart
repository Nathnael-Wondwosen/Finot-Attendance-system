import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ui_components.dart';
import '../../core/typography.dart';
import '../../core/responsive_layout.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/app_provider.dart';
import '../../core/navigation_service.dart';
import 'attendance_screen.dart'; // Import the attendance screen

class ClassSelectionScreen extends ConsumerStatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  ConsumerState<ClassSelectionScreen> createState() =>
      _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends ConsumerState<ClassSelectionScreen> {
  List<ClassEntity> _classes = [];
  List<int> _downloadedClassIds =
      []; // Track which classes have been downloaded
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadDownloadedClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final classRepository = ref.read(classRepositoryProvider);
      final classes = await classRepository.getClasses();

      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading classes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadDownloadedClasses() async {
    try {
      final studentRepository = ref.read(studentRepositoryProvider);
      // Get all students to determine which classes have been downloaded
      final allStudents = await studentRepository.getStudents();

      final downloadedIds = <int>{};
      for (final student in allStudents) {
        if (student.classId != null && student.classId! > 0) {
          downloadedIds.add(student.classId!);
        }
      }

      setState(() {
        _downloadedClassIds = downloadedIds.toList();
      });
    } catch (e) {
      print('Error loading downloaded classes: $e');
    }
  }

  bool _isClassDownloaded(int? classId) {
    return _downloadedClassIds.contains(classId);
  }

  Future<void> _downloadAndShowClassData(ClassEntity classEntity) async {
    try {
      final syncService = ref.read(syncServiceProvider);

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Download students for this specific class from remote API
      final success = await syncService.downloadClassData(
        classEntity.serverId.toString(),
      );

      if (success) {
        // Refresh the downloaded classes list
        await _loadDownloadedClasses();

        // Show the students for this class in a new screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ClassStudentsScreen(
                  classId: classEntity.serverId.toString(),
                  className: classEntity.name,
                ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Class data downloaded successfully! ${classEntity.name} is now available offline.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download class data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading class data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _classes.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No classes available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connect to internet to download classes from the server',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    await _loadClasses();
                    await _loadDownloadedClasses();
                  },
                  child: ListView.builder(
                    itemCount: _classes.length,
                    itemBuilder: (context, index) {
                      final classEntity = _classes[index];
                      final isDownloaded = _isClassDownloaded(
                        classEntity.serverId,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            classEntity.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'ID: ${classEntity.serverId}${isDownloaded ? ' • Downloaded' : ''}',
                            style: TextStyle(
                              color: isDownloaded ? Colors.green : Colors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isDownloaded)
                                Icon(
                                  Icons.download_done,
                                  color: Colors.green,
                                  size: 20,
                                )
                              else
                                Icon(
                                  Icons.download_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          onTap: () => _downloadAndShowClassData(classEntity),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _loadClasses();
          await _loadDownloadedClasses();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// New screen to display students for a specific class
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

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final studentRepository = ref.read(studentRepositoryProvider);
      // Get students for the selected class
      final students = await studentRepository.getStudentsByClass(
        int.tryParse(widget.classId) ?? 0,
      );

      setState(() {
        _students = students;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in ${widget.className}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
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
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                student.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            student.actualGrade ?? 'Grade not specified',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to attendance screen for this class using standard Navigator
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
        label: const Text('Take Attendance'),
        icon: const Icon(Icons.check_circle),
      ),
    );
  }
}
