import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getStudents();
  Future<void> saveStudents(List<StudentEntity> students);
  Future<List<StudentEntity>> getStudentsByClassAndSection(int classId, int sectionId);
}