abstract class SyncRepository {
  Future<void> syncData();
  Future<bool> hasInternetConnection();
  Future<int> getPendingSyncCount();

  // Additional methods for the attendance sync functionality
  Future<bool> downloadClassData(String classId);
  Future<bool> downloadAllClasses();
  Future<bool> uploadAttendanceData();
  Future<bool> isOnline();

  // Method to clear local data
  Future<void> clearLocalData();
}
