class Student {
  final int? id;
  final int? serverId;
  final String name;
  final String? rollNumber;
  final int classId;
  final int sectionId;
  final String? createdAt;
  final String? updatedAt;

  Student({
    this.id,
    this.serverId,
    required this.name,
    this.rollNumber,
    required this.classId,
    required this.sectionId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'roll_number': rollNumber,
      'class_id': classId,
      'section_id': sectionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      serverId: map['server_id'],
      name: map['name'] ?? '',
      rollNumber: map['roll_number'],
      classId: map['class_id']?.toInt() ?? 0,
      sectionId: map['section_id']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // For API response
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      serverId: json['id'],
      name: json['name'] ?? '',
      rollNumber: json['roll_number'],
      classId: json['class_id']?.toInt() ?? 0,
      sectionId: json['section_id']?.toInt() ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}