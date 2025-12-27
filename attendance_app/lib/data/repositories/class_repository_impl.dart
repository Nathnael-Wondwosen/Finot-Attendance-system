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
    // Convert ClassModel to ClassEntity - need to handle String id vs int id
    return classModels.map((model) {
      // Convert string id to int if possible, otherwise use a default
      int? idAsInt;
      try {
        idAsInt = int.tryParse(model.id);
      } catch (e) {
        idAsInt = null; // or some default value
      }
      
      return ClassEntity(
        id: idAsInt,
        serverId: null, // Not used in our schema
        name: model.name,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<void> saveClasses(List<ClassEntity> classes) async {
    // Convert ClassEntity to ClassModel and save to local data source
    final classModels = classes.map((entity) {
      // Convert int id to string
      String id = entity.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      return ClassModel(
        id: id,
        name: entity.name,
        teacherName: null, // Not in entity
        academicYear: 2025, // Default value
        createdAt: DateTime.parse(entity.createdAt ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(entity.updatedAt ?? DateTime.now().toIso8601String()),
      );
    }).toList();
    
    for (final model in classModels) {
      await _localDataSource.insertClass(model);
    }
  }
}