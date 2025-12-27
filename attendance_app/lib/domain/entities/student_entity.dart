class StudentEntity {
  final int? id;
  final int? serverId;
  final String name;
  final String? rollNumber;
  final int classId;
  final int sectionId;
  final String? createdAt;
  final String? updatedAt;

  StudentEntity({
    this.id,
    this.serverId,
    required this.name,
    this.rollNumber,
    required this.classId,
    required this.sectionId,
    this.createdAt,
    this.updatedAt,
  });

  // Adding getters for UI compatibility
  String get fullName => name;
  String? get currentGrade => null; // Placeholder since not in the entity

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
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
}