import '../datasources/local_data_source.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final LocalDataSource _localDataSource;

  StudentRepositoryImpl(this._localDataSource);

  @override
  Future<List<StudentEntity>> getStudents() async {
    final studentModels = await _localDataSource.getStudents();
    // Convert StudentModel to StudentEntity
    final entities =
        studentModels
            .map(
              (model) => StudentEntity(
                id: model.id,
                serverId: model.id, // Use the local id as serverId for now
                name: model.fullName,
                christianName: null, // Not in our schema
                gender: model.gender,
                currentGrade: model.currentGrade,
                photoPath: null, // Not in our schema
                phoneNumber: model.phoneNumber,
                fatherFullName:
                    model.fatherPhone != null
                        ? 'Father'
                        : null, // Placeholder since we only have phone
                fatherPhone: model.fatherPhone,
                motherFullName:
                    model.motherPhone != null
                        ? 'Mother'
                        : null, // Placeholder since we only have phone
                motherPhone: model.motherPhone,
                guardianFullName: null, // Not in our schema
                guardianPhone: null, // Not in our schema
                sourceType: null, // Not in our schema
                rollNumber: null, // Not in our schema
                classId: model.classId ?? 0, // Use the classId from the model
                sectionId: 0, // Not in our schema
                createdAt: model.createdAt.toIso8601String(),
                updatedAt: model.updatedAt.toIso8601String(),
              ),
            )
            .toList();

    print('Retrieved ${entities.length} total students from local database');
    return entities;
  }

  @override
  Future<List<StudentEntity>> getStudentsByClass(int classId) async {
    print('Getting students for class ID: $classId');
    final studentModels = await _localDataSource.getStudentsByClass(
      classId.toString(),
    );
    final entities =
        studentModels
            .map(
              (model) => StudentEntity(
                id: model.id,
                serverId: model.id,
                name: model.fullName,
                christianName: null,
                gender: model.gender,
                currentGrade: model.currentGrade,
                photoPath: null,
                phoneNumber: model.phoneNumber,
                fatherFullName:
                    model.fatherPhone != null ? 'Father' : null, // Placeholder
                fatherPhone: model.fatherPhone,
                motherFullName:
                    model.motherPhone != null ? 'Mother' : null, // Placeholder
                motherPhone: model.motherPhone,
                guardianFullName: null,
                guardianPhone: null,
                sourceType: null,
                rollNumber: null,
                classId: model.classId ?? 0, // Use the classId from the model
                sectionId: 0,
                createdAt: model.createdAt.toIso8601String(),
                updatedAt: model.updatedAt.toIso8601String(),
              ),
            )
            .toList();

    print('Found ${entities.length} students for class ID: $classId');
    return entities;
  }

  @override
  Future<void> saveStudents(List<StudentEntity> students) async {
    print('Saving ${students.length} students to local database');
    final studentModels =
        students
            .map(
              (entity) => StudentModel(
                id: entity.id ?? 0,
                fullName: entity.name,
                gender: entity.gender,
                birthDate: null, // Not in entity
                currentGrade: entity.currentGrade,
                fatherPhone: entity.fatherPhone,
                motherPhone: entity.motherPhone,
                phoneNumber: entity.phoneNumber,
                hasSpiritualFather: null, // Not in entity
                classId: entity.classId, // Added classId
                createdAt: DateTime.parse(
                  entity.createdAt ?? DateTime.now().toIso8601String(),
                ),
                updatedAt: DateTime.parse(
                  entity.updatedAt ?? DateTime.now().toIso8601String(),
                ),
              ),
            )
            .toList();

    await _localDataSource.insertStudents(studentModels);
    print(
      'Successfully saved ${studentModels.length} students to local database',
    );
  }

  @override
  Future<List<StudentEntity>> getStudentsByClassAndSection(
    int classId,
    int sectionId,
  ) async {
    // For now, return students by class only - would need to implement section logic
    return await getStudentsByClass(classId);
  }
}
