import 'package:dio/dio.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';

class RemoteDataSource {
  final Dio _dio;
  static const String _baseUrl =
      'https://attendance.finoteselamss.org/attendance_api.php'; // Using your existing API endpoint

  RemoteDataSource({Dio? dio})
    : _dio =
          dio ?? Dio()
            ..options.connectTimeout = const Duration(seconds: 30);

  // Test connection to the database
  Future<bool> testConnection() async {
    try {
      // This would be a simple endpoint to test connectivity
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'endpoint': 'classes'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Fetch all classes from the remote database
  Future<List<ClassEntity>> fetchClasses() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'endpoint': 'classes'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final classesData = response.data['data'] as List;

        print(
          'RemoteDataSource: Fetched ${classesData.length} classes from API',
        );

        return classesData
            .map(
              (json) => ClassEntity(
                id: json['id'],
                serverId: json['id'],
                name: json['name'] ?? '',
                createdAt:
                    DateTime.now()
                        .toIso8601String(), // Using current time since not in response
                updatedAt: DateTime.now().toIso8601String(),
              ),
            )
            .toList();
      } else {
        print('Failed to fetch classes: ${response.data['error']}');
        return [];
      }
    } catch (e) {
      print('Error fetching classes: $e');
      // Return empty list instead of sample data
      return [];
    }
  }

  // Fetch students by class from the remote database
  Future<List<StudentEntity>> fetchStudentsByClass(int classId) async {
    try {
      // First, try to use the specific endpoint for students by class
      try {
        print(
          'RemoteDataSource: Attempting to fetch students for class ID: $classId',
        );
        final response = await _dio.get(
          _baseUrl,
          queryParameters: {
            'endpoint': 'students_by_class',
            'class_id':
                classId.toString(), // Pass the class ID as a query parameter
          },
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final studentsData = response.data['data'] as List;

          print(
            'RemoteDataSource: Successfully fetched ${studentsData.length} students for class $classId',
          );

          return studentsData
              .map(
                (json) => StudentEntity(
                  id: json['id'],
                  serverId: json['id'],
                  name: json['full_name'] ?? json['name'] ?? 'Unknown Student',
                  christianName: json['christian_name'],
                  gender: json['gender'],
                  currentGrade: json['current_grade'],
                  photoPath: json['photo_path'],
                  phoneNumber: json['phone_number'],
                  fatherFullName: json['father_full_name'],
                  fatherPhone: json['father_phone'],
                  motherFullName: json['mother_full_name'],
                  motherPhone: json['mother_phone'],
                  guardianFullName: json['guardian_full_name'],
                  guardianPhone: json['guardian_phone'],
                  sourceType: json['source_type'],
                  rollNumber: null,
                  classId:
                      classId, // Using the passed classId to properly associate the student with the class
                  sectionId: 0,
                  createdAt:
                      json['created_at']?.toString() ??
                      DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                ),
              )
              .toList();
        } else {
          print(
            'RemoteDataSource: API returned error for class $classId: ${response.data['error']}',
          );
        }
      } catch (e) {
        print(
          'RemoteDataSource: students_by_class endpoint failed for class $classId: $e',
        );
        // If the specific endpoint fails, we'll try to get all students and filter
      }

      // If the specific endpoint doesn't work, we'll try to get all students
      // This is a fallback approach
      print(
        'RemoteDataSource: Using fallback method to get students for class $classId',
      );
      final allStudentsResponse = await _dio.get(
        _baseUrl,
        queryParameters: {'endpoint': 'students'},
      );

      if (allStudentsResponse.statusCode == 200 &&
          allStudentsResponse.data['success'] == true) {
        final allStudentsData = allStudentsResponse.data['data'] as List;

        print(
          'RemoteDataSource: Fallback method returned ${allStudentsData.length} total students, filtering for class $classId',
        );

        // For now, we'll return all students since we can't filter by class from the API
        // In a real implementation, your API should support class-based filtering
        return allStudentsData
            .map(
              (json) => StudentEntity(
                id: json['id'],
                serverId: json['id'],
                name: json['full_name'] ?? json['name'] ?? 'Unknown Student',
                christianName: json['christian_name'],
                gender: json['gender'],
                currentGrade: json['current_grade'],
                photoPath: json['photo_path'],
                phoneNumber: json['phone_number'],
                fatherFullName: json['father_full_name'],
                fatherPhone: json['father_phone'],
                motherFullName: json['mother_full_name'],
                motherPhone: json['mother_phone'],
                guardianFullName: json['guardian_full_name'],
                guardianPhone: json['guardian_phone'],
                sourceType: json['source_type'],
                rollNumber: null,
                classId:
                    classId, // Using the passed classId to associate the student with the class
                sectionId: 0,
                createdAt:
                    json['created_at']?.toString() ??
                    DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
            )
            .toList();
      } else {
        print(
          'RemoteDataSource: Failed to fetch students for class $classId: ${allStudentsResponse.data['error']}',
        );
        return [];
      }
    } catch (e) {
      print('RemoteDataSource: Error fetching students for class $classId: $e');
      // Return empty list instead of sample data
      return [];
    }
  }

  // Fetch all students from the remote database
  Future<List<StudentEntity>> fetchAllStudents() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'endpoint': 'students'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final studentsData = response.data['data'] as List;

        print(
          'RemoteDataSource: Fetched ${studentsData.length} total students from API',
        );

        return studentsData
            .map(
              (json) => StudentEntity(
                id: json['id'],
                serverId: json['id'],
                name: json['full_name'] ?? json['name'] ?? 'Unknown Student',
                christianName: json['christian_name'],
                gender: json['gender'],
                currentGrade: json['current_grade'],
                photoPath: json['photo_path'],
                phoneNumber: json['phone_number'],
                fatherFullName: json['father_full_name'],
                fatherPhone: json['father_phone'],
                motherFullName: json['mother_full_name'],
                motherPhone: json['mother_phone'],
                guardianFullName: json['guardian_full_name'],
                guardianPhone: json['guardian_phone'],
                sourceType: json['source_type'],
                rollNumber: null,
                classId:
                    0, // Using 0 since we don't have class info in this response
                sectionId: 0,
                createdAt:
                    json['created_at']?.toString() ??
                    DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
            )
            .toList();
      } else {
        print('Failed to fetch students: ${response.data['error']}');
        return [];
      }
    } catch (e) {
      print('Error fetching students: $e');
      // Return empty list instead of sample data
      return [];
    }
  }

  // Submit attendance to the remote database
  Future<bool> submitAttendance(
    List<Map<String, dynamic>> attendanceData,
  ) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        queryParameters: {'endpoint': 'attendance'},
        data: {
          'attendance_data': attendanceData,
          'date': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error submitting attendance: $e');
      return false;
    }
  }
}
