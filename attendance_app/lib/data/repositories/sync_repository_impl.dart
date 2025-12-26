import '../../domain/repositories/sync_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

class SyncRepositoryImpl implements SyncRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  SyncRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> syncData() async {
    try {
      final attendanceList = await _localDataSource.getUnsyncedAttendance();
      if (attendanceList.isNotEmpty) {
        // Convert AttendanceModel to AttendanceEntity for the remote call
        await _remoteDataSource.syncAttendance(attendanceList);
        // Mark as synced after successful sync
        for (var attendance in attendanceList) {
          await _localDataSource.markAttendanceAsSynced(attendance.id!);
        }
      }
    } catch (e) {
      // Log error but don't throw to prevent app from crashing
      print('Sync error: $e');
    }
  }

  @override
  Future<bool> hasInternetConnection() async {
    // This would require connectivity package implementation
    // For now, returning true - in real app you'd check actual connectivity
    return true;
  }

  @override
  Future<int> getPendingSyncCount() async {
    final attendanceList = await _localDataSource.getUnsyncedAttendance();
    return attendanceList.length;
  }
}