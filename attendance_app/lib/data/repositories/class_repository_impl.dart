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
    return classModels.map((model) => ClassEntity(
      id: int.tryParse(model.id ?? '0'), // Convert String id to int
      serverId: int.tryParse(model.id ?? '0'), // Use the same value for serverId
      name: model.name,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
    )).toList();
  }

  @override
  Future<void> saveClasses(List<ClassEntity> classes) async {
    final classModels = classes.map((entity) => ClassModel(
      id: entity.serverId?.toString() ?? entity.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: entity.name,
      teacherName: null, // Not in entity
      academicYear: DateTime.now().year, // Default value
      createdAt: DateTime.parse(entity.createdAt ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(entity.updatedAt ?? DateTime.now().toIso8601String()),
    )).toList();
    
    for (final model in classModels) {
      await _localDataSource.insertClass(model);
    }
  }
}