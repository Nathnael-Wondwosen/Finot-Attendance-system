import 'package:attendance_app/core/constants.dart';

class AttendanceEntity {
  final int? id;
  final int studentId;
  final int classId;
  final int sectionId;
  final String date;
  final String status; // present, absent, late
  final int synced; // 0 = not synced, 1 = synced
  final String? createdAt;
  final String? updatedAt;

  AttendanceEntity({
    this.id,
    required this.studentId,
    required this.classId,
    required this.sectionId,
    required this.date,
    this.status = AppConstants.present,
    this.synced = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'section_id': sectionId,
      'date': date,
      'status': status,
      'synced': synced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}