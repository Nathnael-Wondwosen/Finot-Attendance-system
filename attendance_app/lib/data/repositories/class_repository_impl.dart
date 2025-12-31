import '../datasources/local_data_source.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/entities/class_entity.dart';
import '../models/class_model.dart';

class ClassRepositoryImpl implements ClassRepository {
  final LocalDataSource _localDataSource;

  ClassRepositoryImpl(this._localDataSource);

  @override
  Future<List<ClassEntity>> getClasses() async {
    final classModels = await _localDataSource.getClasses();
    return classModels
        .map(
          (model) => ClassEntity(
            id: model.id,
            serverId: model.serverId,
            name: model.name,
            createdAt: model.createdAt?.toIso8601String(),
            updatedAt: model.updatedAt?.toIso8601String(),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveClasses(List<ClassEntity> classes) async {
    final classModels =
        classes
            .map(
              (entity) => ClassModel(
                id: entity.id,
                serverId: entity.serverId,
                name: entity.name,
                createdAt:
                    entity.createdAt != null
                        ? DateTime.parse(entity.createdAt!)
                        : null,
                updatedAt:
                    entity.updatedAt != null
                        ? DateTime.parse(entity.updatedAt!)
                        : null,
              ),
            )
            .toList();

    for (final model in classModels) {
      await _localDataSource.insertClass(model);
    }
  }
}
