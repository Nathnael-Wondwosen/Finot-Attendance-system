import '../../domain/repositories/section_repository.dart';
import '../datasources/local_data_source.dart';
import '../../domain/entities/section_entity.dart';
import '../models/section_model.dart';

class SectionRepositoryImpl implements SectionRepository {
  final LocalDataSource _localDataSource;

  SectionRepositoryImpl(this._localDataSource);

  @override
  Future<List<SectionEntity>> getSections() async {
    final sections = await _localDataSource.getSections();
    return sections.map((model) => SectionEntity(
      id: model.id,
      serverId: model.serverId,
      name: model.name,
      classId: model.classId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<void> saveSections(List<SectionEntity> sections) async {
    final models = sections.map((entity) => SectionModel(
      id: entity.id,
      serverId: entity.serverId,
      name: entity.name,
      classId: entity.classId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    )).toList();
    await _localDataSource.saveSections(models);
  }

  @override
  Future<List<SectionEntity>> getSectionsByClass(int classId) async {
    final sections = await _localDataSource.getSectionsByClass(classId);
    return sections.map((model) => SectionEntity(
      id: model.id,
      serverId: model.serverId,
      name: model.name,
      classId: model.classId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }
}