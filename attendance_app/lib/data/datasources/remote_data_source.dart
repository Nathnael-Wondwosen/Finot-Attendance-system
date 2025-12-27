import 'package:dio/dio.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';

class RemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://finoteselamss.org'; // Using your host
  
  RemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  // Test connection to the database
  Future<bool> testConnection() async {
    try {
      // This would be a simple endpoint to test connectivity
      final response = await _dio.get('$_baseUrl/api/health'); // Placeholder endpoint
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Fetch all classes from the remote database
  Future<List<ClassEntity>> fetchClasses() async {
    try {
      final response = await _dio.get('$_baseUrl/api/classes'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ClassEntity(
          id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
          serverId: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
          name: json['name'] ?? '',
          createdAt: json['created_at']?.toString(),
          updatedAt: json['updated_at']?.toString(),
        )).toList();
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      // In case of error, return empty list or throw error
      print('Error fetching classes: $e');
      return []; // Return empty list as fallback
    }
  }

  // Fetch students for a specific class
  Future<List<StudentEntity>> fetchStudentsByClass(String classId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/classes/$classId/students'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StudentEntity(
          id: json['id']?.toInt() ?? 0,
          serverId: json['id']?.toInt(),
          name: json['full_name'] ?? json['name'] ?? '',
          rollNumber: json['roll_number'],
          classId: json['class_id']?.toInt() ?? 0,
          sectionId: json['section_id']?.toInt() ?? 0,
          createdAt: json['created_at']?.toString(),
          updatedAt: json['updated_at']?.toString(),
        )).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students for class $classId: $e');
      return []; // Return empty list as fallback
    }
  }

  // Fetch all students
  Future<List<StudentEntity>> fetchAllStudents() async {
    try {
      final response = await _dio.get('$_baseUrl/api/students'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StudentEntity(
          id: json['id']?.toInt() ?? 0,
          serverId: json['id']?.toInt(),
          name: json['full_name'] ?? json['name'] ?? '',
          rollNumber: json['roll_number'],
          classId: json['class_id']?.toInt() ?? 0,
          sectionId: json['section_id']?.toInt() ?? 0,
          createdAt: json['created_at']?.toString(),
          updatedAt: json['updated_at']?.toString(),
        )).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all students: $e');
      return []; // Return empty list as fallback
    }
  }

  // Submit attendance records to the server
  Future<bool> submitAttendance(List<AttendanceEntity> attendanceRecords) async {
    try {
      final List<Map<String, dynamic>> recordsData = 
          attendanceRecords.map((record) => record.toDto()).toList();
      
      final response = await _dio.post(
        '$_baseUrl/api/attendance/submit', // Actual endpoint needed
        data: {'records': recordsData},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to submit attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting attendance: $e');
      return false;
    }
  }

  // Sync attendance records
  Future<bool> syncAttendance(List<AttendanceEntity> attendanceRecords) async {
    try {
      final List<Map<String, dynamic>> unsyncedRecords = attendanceRecords
          .where((record) => record.synced == 0)
          .map((record) => record.toDto())
          .toList();
      
      if (unsyncedRecords.isEmpty) {
        return true; // Nothing to sync
      }
      
      final response = await _dio.post(
        '$_baseUrl/api/attendance/sync', // Actual endpoint needed
        data: {'records': unsyncedRecords},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to sync attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing attendance: $e');
      return false;
    }
  }
}