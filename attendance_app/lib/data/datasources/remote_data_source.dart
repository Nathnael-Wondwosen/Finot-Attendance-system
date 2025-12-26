import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/section_model.dart';
import '../models/attendance_model.dart';

class RemoteDataSource {
  final Dio _dio = Dio();

  Future<void> init() async {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Fetch initial data
  Future<List<Student>> fetchStudents() async {
    try {
      final response = await _dio.get('/students');
      if (response.data is List) {
        return response.data.map((json) => Student.fromJson(json)).toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => Student.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<List<ClassModel>> fetchClasses() async {
    try {
      final response = await _dio.get('/classes');
      if (response.data is List) {
        return response.data.map((json) => ClassModel.fromJson(json)).toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => ClassModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch classes: $e');
    }
  }

  Future<List<SectionModel>> fetchSections() async {
    try {
      final response = await _dio.get('/sections');
      if (response.data is List) {
        return response.data.map((json) => SectionModel.fromJson(json)).toList();
      } else if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => SectionModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sections: $e');
    }
  }

  // Sync attendance data
  Future<void> syncAttendance(List<AttendanceModel> attendanceList) async {
    try {
      final data = {
        'attendances': attendanceList.map((attendance) => {
          'student_id': attendance.studentId,
          'class_id': attendance.classId,
          'section_id': attendance.sectionId,
          'date': attendance.date,
          'status': attendance.status,
        }).toList(),
      };
      
      await _dio.post('/attendance/sync', data: data);
    } catch (e) {
      throw Exception('Failed to sync attendance: $e');
    }
  }

  // Set auth token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}