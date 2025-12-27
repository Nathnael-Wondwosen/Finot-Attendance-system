import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/student_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;

  SyncRepositoryImpl(this._localDataSource, this._remoteDataSource, this._classRepository, this._studentRepository);

  @override
  Future<void> syncData() async {
    try {
      // This would implement the full sync process
      // For now, it's a placeholder
    } catch (e) {
      print('Error syncing data: $e');
      throw e;
    }
  }

  @override
  Future<bool> hasInternetConnection() async {
    try {
      return await _remoteDataSource.testConnection();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    // This would return the count of unsynced records
    // For now, returning 0 as a placeholder
    return 0;
  }

  // Additional methods for the attendance sync functionality
  Future<bool> downloadClassData(String classId) async {
    try {
      // Get students for this class from remote
      final remoteStudents = await _remoteDataSource.fetchStudentsByClass(classId);
      
      // Save students to local storage
      await _studentRepository.saveStudents(remoteStudents);
      
      return true;
    } catch (e) {
      print('Error downloading class data: $e');
      return false;
    }
  }

  Future<bool> downloadAllClasses() async {
    try {
      // Get all classes from remote
      final remoteClasses = await _remoteDataSource.fetchClasses();
      
      // Save classes to local storage
      await _classRepository.saveClasses(remoteClasses);
      
      // For each class, get its students
      for (final classEntity in remoteClasses) {
        try {
          final remoteStudents = await _remoteDataSource.fetchStudentsByClass(classEntity.serverId.toString());
          await _studentRepository.saveStudents(remoteStudents);
        } catch (e) {
          print('Error downloading students for class ${classEntity.name}: $e');
          // Continue with other classes even if one fails
        }
      }
      
      return true;
    } catch (e) {
      print('Error downloading all classes: $e');
      return false;
    }
  }

  Future<bool> uploadAttendanceData() async {
    try {
      // Get unsynced attendance records from local storage
      // For now, we'll just return success
      // In a real implementation, we would get unsynced records and upload them
      return true;
    } catch (e) {
      print('Error uploading attendance data: $e');
      return false;
    }
  }

  Future<bool> isOnline() async {
    try {
      return await _remoteDataSource.testConnection();
    } catch (e) {
      return false;
    }
  }
}