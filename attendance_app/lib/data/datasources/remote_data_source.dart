import 'package:dio/dio.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';

class RemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://attendance.finoteselamss.org'; // Using your subdomain
  
  RemoteDataSource({Dio? dio}) : _dio = dio ?? Dio()..options.connectTimeout = const Duration(seconds: 30);

  // Test connection to the database
  Future<bool> testConnection() async {
    try {
      // This would be a simple endpoint to test connectivity
      final response = await _dio.get('$_baseUrl/health'); // Placeholder endpoint
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Fetch all classes from the remote database
  Future<List<ClassEntity>> fetchClasses() async {
    try {
      final response = await _dio.get('$_baseUrl/classes'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => ClassEntity(
          id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
          serverId: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
          name: json['name'] ?? json['class_name'] ?? '',
          createdAt: json['created_at']?.toString(),
          updatedAt: json['updated_at']?.toString(),
        )).toList();
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      // In case of error, return empty list or throw error
      print('Error fetching classes: $e');
      // For demo purposes, return some sample classes
      return [
        ClassEntity(
          id: 1,
          serverId: 1,
          name: 'Mathematics',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        ClassEntity(
          id: 2,
          serverId: 2,
          name: 'Science',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        ClassEntity(
          id: 3,
          serverId: 3,
          name: 'English',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ]; // Return sample data as fallback
    }
  }

  // Fetch students for a specific class
  Future<List<StudentEntity>> fetchStudentsByClass(String classId) async {
    try {
      final response = await _dio.get('$_baseUrl/classes/$classId/students'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => StudentEntity(
          id: json['id']?.toInt() ?? 0,
          serverId: json['id']?.toInt(),
          name: json['full_name'] ?? json['name'] ?? json['student_name'] ?? '',
          rollNumber: json['roll_number'] ?? json['student_id'],
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
      // For demo purposes, return some sample students
      return [
        StudentEntity(
          id: 1,
          serverId: 1,
          name: 'John Doe',
          rollNumber: '001',
          classId: int.tryParse(classId) ?? 0,
          sectionId: 1,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        StudentEntity(
          id: 2,
          serverId: 2,
          name: 'Jane Smith',
          rollNumber: '002',
          classId: int.tryParse(classId) ?? 0,
          sectionId: 1,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        StudentEntity(
          id: 3,
          serverId: 3,
          name: 'Robert Johnson',
          rollNumber: '003',
          classId: int.tryParse(classId) ?? 0,
          sectionId: 1,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ]; // Return sample data as fallback
    }
  }

  // Fetch all students
  Future<List<StudentEntity>> fetchAllStudents() async {
    try {
      final response = await _dio.get('$_baseUrl/students'); // Actual endpoint needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((json) => StudentEntity(
          id: json['id']?.toInt() ?? 0,
          serverId: json['id']?.toInt(),
          name: json['full_name'] ?? json['name'] ?? json['student_name'] ?? '',
          rollNumber: json['roll_number'] ?? json['student_id'],
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
        '$_baseUrl/attendance/submit', // Actual endpoint needed
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
        '$_baseUrl/attendance/sync', // Actual endpoint needed
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