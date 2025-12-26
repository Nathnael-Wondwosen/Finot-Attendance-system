abstract class SyncRepository {
  Future<void> syncData();
  Future<bool> hasInternetConnection();
  Future<int> getPendingSyncCount();
}