import '../domain/repositories/sync_repository.dart';
import '../domain/repositories/class_repository.dart';
import '../domain/repositories/student_repository.dart';
import '../domain/repositories/attendance_repository.dart';

class SyncService {
  final SyncRepository _syncRepository;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;
  final AttendanceRepository _attendanceRepository;

  SyncService(
    this._syncRepository,
    this._classRepository,
    this._studentRepository,
    this._attendanceRepository,
  );

  // Download students for a specific class from remote to local
  Future<bool> downloadClassData(String classId) async {
    try {
      // Use the sync repository to download students for the specific class
      return await _syncRepository.downloadClassData(classId);
    } catch (e) {
      print('Error downloading class data: $e');
      return false;
    }
  }

  // Download all classes and their students from remote to local
  Future<bool> downloadAllClasses() async {
    try {
      return await _syncRepository.downloadAllClasses();
    } catch (e) {
      print('Error downloading all classes: $e');
      return false;
    }
  }

  // Upload attendance data from local to remote
  Future<bool> uploadAttendanceData() async {
    try {
      return await _syncRepository.uploadAttendanceData();
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

  // Check if there's internet connection
  Future<bool> hasInternetConnection() async {
    try {
      return await _syncRepository.hasInternetConnection();
    } catch (e) {
      return false;
    }
  }

  // Check if the device is online
  Future<bool> isOnline() async {
    try {
      return await _syncRepository.isOnline();
    } catch (e) {
      return false;
    }
  }

  // Get the count of pending sync items
  Future<int> getPendingSyncCount() async {
    try {
      return await _syncRepository.getPendingSyncCount();
    } catch (e) {
      return 0;
    }
  }

  // Sync all data (download and upload)
  Future<void> syncAllData() async {
    try {
      await _syncRepository.syncData();
    } catch (e) {
      print('Error syncing all data: $e');
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

  // Clear local data from SQLite database
  Future<bool> clearLocalData() async {
    try {
      await _syncRepository.clearLocalData();
      return true;
    } catch (e) {
      print('Error clearing local data: $e');
      return false;
    }
  }
}
