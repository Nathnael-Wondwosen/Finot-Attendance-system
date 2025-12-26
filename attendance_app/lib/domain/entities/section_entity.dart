class SectionEntity {
  final int? id;
  final int? serverId;
  final String name;
  final int classId;
  final String? createdAt;
  final String? updatedAt;

  SectionEntity({
    this.id,
    this.serverId,
    required this.name,
    required this.classId,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'class_id': classId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}