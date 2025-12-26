class ClassModel {
  final int? id;
  final int? serverId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  ClassModel({
    this.id,
    this.serverId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      serverId: map['server_id'],
      name: map['name'] ?? '',
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // For API response
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      serverId: json['id'],
      name: json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}