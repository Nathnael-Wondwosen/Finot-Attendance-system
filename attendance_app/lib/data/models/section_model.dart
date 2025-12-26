class SectionModel {
  final int? id;
  final int? serverId;
  final String name;
  final int classId;
  final String? createdAt;
  final String? updatedAt;

  SectionModel({
    this.id,
    this.serverId,
    required this.name,
    required this.classId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'class_id': classId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(
      id: map['id'],
      serverId: map['server_id'],
      name: map['name'] ?? '',
      classId: map['class_id']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // For API response
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      serverId: json['id'],
      name: json['name'] ?? '',
      classId: json['class_id']?.toInt() ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}