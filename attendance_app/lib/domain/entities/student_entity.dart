class StudentEntity {
  final int? id;
  final int? serverId;
  final String name;
  final String? christianName;
  final String? gender;
  final String? currentGrade;
  final String? photoPath;
  final String? phoneNumber;
  final String? fatherFullName;
  final String? fatherPhone;
  final String? motherFullName;
  final String? motherPhone;
  final String? guardianFullName;
  final String? guardianPhone;
  final String? sourceType;
  final String? rollNumber;
  final int classId;
  final int sectionId;
  final String? createdAt;
  final String? updatedAt;

  StudentEntity({
    this.id,
    this.serverId,
    required this.name,
    this.christianName,
    this.gender,
    this.currentGrade,
    this.photoPath,
    this.phoneNumber,
    this.fatherFullName,
    this.fatherPhone,
    this.motherFullName,
    this.motherPhone,
    this.guardianFullName,
    this.guardianPhone,
    this.sourceType,
    this.rollNumber,
    required this.classId,
    required this.sectionId,
    this.createdAt,
    this.updatedAt,
  });

  // Adding getters for UI compatibility
  String get fullName => name;
  String? get actualGrade => currentGrade; // Use the actual field value

  // Convert to DTO for data layer
  Map<String, dynamic> toDto() {
    return {
      'id': id,
      'server_id': serverId,
      'name': name,
      'christian_name': christianName,
      'gender': gender,
      'current_grade': currentGrade,
      'photo_path': photoPath,
      'phone_number': phoneNumber,
      'father_full_name': fatherFullName,
      'father_phone': fatherPhone,
      'mother_full_name': motherFullName,
      'mother_phone': motherPhone,
      'guardian_full_name': guardianFullName,
      'guardian_phone': guardianPhone,
      'source_type': sourceType,
      'roll_number': rollNumber,
      'class_id': classId,
      'section_id': sectionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
