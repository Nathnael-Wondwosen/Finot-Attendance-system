import '../entities/section_entity.dart';

abstract class SectionRepository {
  Future<List<SectionEntity>> getSections();
  Future<void> saveSections(List<SectionEntity> sections);
  Future<List<SectionEntity>> getSectionsByClass(int classId);
}