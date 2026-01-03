import '../../domain/repositories/section_repository.dart';
import '../../domain/entities/section_entity.dart';

class SectionRepositoryImpl implements SectionRepository {
  SectionRepositoryImpl();

  @override
  Future<List<SectionEntity>> getSections() async {
    // Since your database doesn't have explicit sections, return empty list
    // In a real implementation, you might map from your class structure
    return [];
  }

  @override
  Future<void> saveSections(List<SectionEntity> sections) async {
    // Since your database doesn't have explicit sections, this is a no-op
    // In a real implementation, you might save to your class structure
  }

  @override
  Future<List<SectionEntity>> getSectionsByClass(int classId) async {
    // Since your database doesn't have explicit sections, return empty list
    // In a real implementation, you might map from your class structure
    return [];
  }
}
