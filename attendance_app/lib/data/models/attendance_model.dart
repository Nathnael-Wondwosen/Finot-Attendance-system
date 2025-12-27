class AttendanceModel {
  final int id;
  final int studentId;
  final String classId;  // Changed to String to match database schema
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced; // Whether this record has been synced to the server

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id']?.toInt() ?? 0,
      studentId: map['student_id']?.toInt() ?? 0,
      classId: map['class_id'] ?? '',
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'present',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      synced: map['synced'] == 1,
    );
  }

  AttendanceModel copyWith({
    int? id,
    int? studentId,
    String? classId,
    DateTime? date,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}