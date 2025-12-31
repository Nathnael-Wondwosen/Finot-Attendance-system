import 'package:attendance_app/core/constants.dart';

class AttendanceEntity {
  final int? id;
  final int studentId;
  final int classId;
  final String? className;
  final int sectionId;
  final String date;
  final String status; // present, absent, late
  final int synced; // 0 = not synced, 1 = synced
  final String? createdAt;
  final String? updatedAt;
  final DateTime? attendanceDate;

  AttendanceEntity({
    this.id,
    required this.studentId,
    required this.classId,
    this.className,
    this.sectionId = 0,
    required this.date,
    this.status = AppConstants.present,
    this.synced = 0,
    this.createdAt,
    this.updatedAt,
    this.attendanceDate,
  });

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'date': date,
      'status': status,
      'synced': synced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'class_name': className,
      'date': date,
      'status': status,
      'synced': synced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Create from map for database operations
  factory AttendanceEntity.fromMap(Map<String, dynamic> map) {
    return AttendanceEntity(
      id: map['id']?.toInt(),
      studentId: map['student_id']?.toInt() ?? 0,
      classId: map['class_id']?.toInt() ?? 0,
      className: map['class_name'],
      date: map['date'] ?? '',
      status: map['status'] ?? 'present',
      synced: map['synced']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
