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
    return studentModels.map((model) => StudentEntity(
      id: model.id,
      serverId: model.id, // Use the local id as serverId for now
      name: model.fullName,
      rollNumber: null, // Not in our schema
      classId: 0, // Not directly in our schema
      sectionId: 0, // Not in our schema
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    )).toList();
  }

  @override
  Future<void> saveStudents(List<StudentEntity> students) async {
    // Convert StudentEntity to StudentModel and save to local data source
    final studentModels = students.map((entity) => StudentModel(
      id: entity.id ?? 0,
      fullName: entity.name,
      gender: null, // Not in entity
      birthDate: null, // Not in entity
      currentGrade: null, // Not in entity
      fatherPhone: null, // Not in entity
      motherPhone: null, // Not in entity
      phoneNumber: null, // Not in entity
      hasSpiritualFather: null, // Not in entity
      createdAt: DateTime.parse(entity.createdAt ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(entity.updatedAt ?? DateTime.now().toIso8601String()),
    )).toList();
    
    await _localDataSource.insertStudents(studentModels);
  }

  @override
  Future<List<StudentEntity>> getStudentsByClass(int classId) async {
    // For now, return all students - in a real implementation, this would query by class
    // Since our local database doesn't have a direct class relationship in the student table,
    // we'll return all students but in a real app you would query based on class
    final studentModels = await _localDataSource.getStudents();
    // Convert StudentModel to StudentEntity
    return studentModels.map((model) => StudentEntity(
      id: model.id,
      serverId: model.id, // Use the local id as serverId for now
      name: model.fullName,
      rollNumber: null, // Not in our schema
      classId: classId, // Use the provided classId
      sectionId: 0, // Not in our schema
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    )).toList();
  }

  @override
  Future<List<StudentEntity>> getStudentsByClassAndSection(int classId, int sectionId) async {
    // For now, return all students - would need to implement class/section logic
    return await getStudents();
  }
}