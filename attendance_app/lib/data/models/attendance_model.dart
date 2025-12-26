import 'package:attendance_app/core/constants.dart';

class AttendanceModel {
  final int? id;
  final int studentId;
  final int classId;
  final int sectionId;
  final String date;
  final String status; // present, absent, late
  final int synced; // 0 = not synced, 1 = synced
  final String? createdAt;
  final String? updatedAt;

  AttendanceModel({
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

  Map<String, dynamic> toMap() {
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

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      studentId: map['student_id']?.toInt() ?? 0,
      classId: map['class_id']?.toInt() ?? 0,
      sectionId: map['section_id']?.toInt() ?? 0,
      date: map['date'] ?? '',
      status: map['status'] ?? AppConstants.present,
      synced: map['synced']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // For API response
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentId: json['student_id']?.toInt() ?? 0,
      classId: json['class_id']?.toInt() ?? 0,
      sectionId: json['section_id']?.toInt() ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? AppConstants.present,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  AttendanceModel copyWith({
    int? id,
    int? studentId,
    int? classId,
    int? sectionId,
    String? date,
    String? status,
    int? synced,
    String? createdAt,
    String? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      status: status ?? this.status,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}