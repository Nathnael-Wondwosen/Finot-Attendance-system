class ClassEntity {
  final int? id;
  final int? serverId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  ClassEntity({
    this.id,
    this.serverId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}