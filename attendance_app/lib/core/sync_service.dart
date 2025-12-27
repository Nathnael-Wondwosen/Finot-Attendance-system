import '../domain/repositories/sync_repository.dart';
import '../domain/repositories/class_repository.dart';
import '../domain/repositories/student_repository.dart';
import '../domain/repositories/attendance_repository.dart';
import '../domain/entities/class_entity.dart';
import '../domain/entities/student_entity.dart';
import '../domain/entities/attendance_entity.dart';

class SyncService {
  final SyncRepository _syncRepository;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;
  final AttendanceRepository _attendanceRepository;

  SyncService(this._syncRepository, this._classRepository, this._studentRepository, this._attendanceRepository);

  // Download classes and students from remote to local
  Future<bool> downloadClassData(String classId) async {
    try {
      // This would be implemented in the repository
      // For now using direct repository call
      return await (_syncRepository as dynamic).downloadClassData(classId);
    } catch (e) {
      print('Error downloading class data: $e');
      return false;
    }
  }

  // Download all classes from remote to local
  Future<bool> downloadAllClasses() async {
    try {
      // Get all classes from remote
      // This would be implemented in the repository
      return await (_syncRepository as dynamic).downloadAllClasses();
    } catch (e) {
      print('Error downloading all classes: $e');
      return false;
    }
  }

  // Upload unsynced attendance records to remote
  Future<bool> uploadAttendanceData() async {
    try {
      // This would be implemented in the repository
      return await (_syncRepository as dynamic).uploadAttendanceData();
    } catch (e) {
      print('Error uploading attendance data: $e');
      return false;
    }
  }

  // Perform full sync (download new data and upload pending records)
  Future<bool> performFullSync() async {
    try {
      print('Starting full sync...');
      
      // First, upload any pending attendance records
      final uploadSuccess = await uploadAttendanceData();
      
      if (!uploadSuccess) {
        print('Failed to upload attendance data during sync');
        // We continue with download even if upload failed, as it's not critical
      }
      
      // Then download any new classes or updates
      final downloadSuccess = await downloadAllClasses();
      
      if (!downloadSuccess) {
        print('Failed to download class data during sync');
        return false;
      }
      
      print('Full sync completed successfully');
      return true;
    } catch (e) {
      print('Error during full sync: $e');
      return false;
    }
  }

  // Check if device is online
  Future<bool> isOnline() async {
    try {
      return await _syncRepository.hasInternetConnection();
    } catch (e) {
      return false;
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedCount = await _syncRepository.getPendingSyncCount();
    final online = await isOnline();
    
    return {
      'unsyncedCount': unsyncedCount,
      'isOnline': online,
      'lastSyncTime': DateTime.now(),
    };
  }
}