import '../../domain/repositories/class_repository.dart';
import '../datasources/local_data_source.dart';
import '../../domain/entities/class_entity.dart';
import '../models/class_model.dart';

class ClassRepositoryImpl implements ClassRepository {
  final LocalDataSource _localDataSource;

  ClassRepositoryImpl(this._localDataSource);

  @override
  Future<List<ClassEntity>> getClasses() async {
    final classes = await _localDataSource.getClasses();
    return classes.map((model) => ClassEntity(
      id: model.id,
      serverId: model.serverId,
      name: model.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<void> saveClasses(List<ClassEntity> classes) async {
    final models = classes.map((entity) => ClassModel(
      id: entity.id,
      serverId: entity.serverId,
      name: entity.name,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    )).toList();
    await _localDataSource.saveClasses(models);
  }
}