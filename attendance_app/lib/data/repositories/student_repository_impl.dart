import '../../domain/repositories/student_repository.dart';
import '../datasources/local_data_source.dart';
import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final LocalDataSource _localDataSource;

  StudentRepositoryImpl(this._localDataSource);

  @override
  Future<List<StudentEntity>> getStudents() async {
    final students = await _localDataSource.getStudents();
    return students.map((model) => StudentEntity(
      id: model.id,
      serverId: model.serverId,
      name: model.name ?? '',
      rollNumber: model.rollNumber,
      classId: model.classId,
      sectionId: model.sectionId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<void> saveStudents(List<StudentEntity> students) async {
    final models = students.map((entity) => Student(
      id: entity.id,
      serverId: entity.serverId,
      name: entity.name,
      rollNumber: entity.rollNumber,
      classId: entity.classId,
      sectionId: entity.sectionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    )).toList();
    await _localDataSource.saveStudents(models);
  }

  @override
  Future<List<StudentEntity>> getStudentsByClassAndSection(int classId, int sectionId) async {
    final students = await _localDataSource.getStudentsByClassAndSection(classId, sectionId);
    return students.map((model) => StudentEntity(
      id: model.id,
      serverId: model.serverId,
      name: model.name ?? '',
      rollNumber: model.rollNumber,
      classId: model.classId,
      sectionId: model.sectionId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }
}