class StudentModel {
  final int id;
  final String fullName;
  final String? gender;
  final String? birthDate;
  final String? currentGrade;
  final String? fatherPhone;
  final String? motherPhone;
  final String? phoneNumber;
  final String? hasSpiritualFather;
  final int? classId; // Added classId field
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.fullName,
    this.gender,
    this.birthDate,
    this.currentGrade,
    this.fatherPhone,
    this.motherPhone,
    this.phoneNumber,
    this.hasSpiritualFather,
    this.classId, // Added classId parameter
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate,
      'current_grade': currentGrade,
      'father_phone': fatherPhone,
      'mother_phone': motherPhone,
      'phone_number': phoneNumber,
      'has_spiritual_father': hasSpiritualFather,
      'class_id': classId, // Added classId to map
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toInt() ?? 0,
      fullName: map['full_name']?.toString() ?? '',
      gender: map['gender']?.toString(),
      birthDate: map['birth_date']?.toString(),
      currentGrade: map['current_grade']?.toString(),
      fatherPhone: map['father_phone']?.toString(),
      motherPhone: map['mother_phone']?.toString(),
      phoneNumber: map['phone_number']?.toString(),
      hasSpiritualFather: map['has_spiritual_father']?.toString(),
      classId: map['class_id']?.toInt(), // Added classId from map
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
