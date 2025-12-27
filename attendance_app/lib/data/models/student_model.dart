class StudentModel {
  final int id;
  final String fullName;
  final String? gender;
  final DateTime? birthDate;
  final String? currentGrade;
  final String? fatherPhone;
  final String? motherPhone;
  final String? phoneNumber;
  final String? hasSpiritualFather;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    required this.id,
    required this.fullName,
    this.gender,
    this.birthDate,
    this.currentGrade,
    this.fatherPhone,
    this.motherPhone,
    this.phoneNumber,
    this.hasSpiritualFather,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'current_grade': currentGrade,
      'father_phone': fatherPhone,
      'mother_phone': motherPhone,
      'phone_number': phoneNumber,
      'has_spiritual_father': hasSpiritualFather,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toInt() ?? 0,
      fullName: map['full_name'] ?? '',
      gender: map['gender'],
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      currentGrade: map['current_grade'],
      fatherPhone: map['father_phone'],
      motherPhone: map['mother_phone'],
      phoneNumber: map['phone_number'],
      hasSpiritualFather: map['has_spiritual_father'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  StudentModel copyWith({
    int? id,
    String? fullName,
    String? gender,
    DateTime? birthDate,
    String? currentGrade,
    String? fatherPhone,
    String? motherPhone,
    String? phoneNumber,
    String? hasSpiritualFather,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      currentGrade: currentGrade ?? this.currentGrade,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      motherPhone: motherPhone ?? this.motherPhone,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hasSpiritualFather: hasSpiritualFather ?? this.hasSpiritualFather,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}