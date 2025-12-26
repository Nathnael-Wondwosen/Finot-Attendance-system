class SyncQueueModel {
  final int? id;
  final String tableName;
  final int recordId;
  final String action; // insert, update, delete
  final String data;
  final int synced; // 0 = not synced, 1 = synced
  final String? createdAt;
  final String? updatedAt;

  SyncQueueModel({
    this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    required this.data,
    this.synced = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data,
      'synced': synced,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'],
      tableName: map['table_name'] ?? '',
      recordId: map['record_id']?.toInt() ?? 0,
      action: map['action'] ?? '',
      data: map['data'] ?? '',
      synced: map['synced']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}