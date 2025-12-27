import '../datasources/local_data_source.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalDataSource _localDataSource;

  AttendanceRepositoryImpl(this._localDataSource);

  @override
  Future<List<AttendanceEntity>> getAttendanceByDate(String date) async {
    // This method doesn't exist in our LocalDataSource
    // For now, return all attendance records
    final attendanceModels = await _localDataSource.getUnsyncedAttendance();
    return attendanceModels.map((model) {
      // Convert String classId to int if possible
      int classIdAsInt;
      try {
        classIdAsInt = int.parse(model.classId);
      } catch (e) {
        classIdAsInt = 0; // Default to 0 if conversion fails
      }
      
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: classIdAsInt,
        sectionId: 0, // Not in our schema
        date: model.date.toIso8601String(),
        status: model.status,
        synced: model.synced ? 1 : 0,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByClassSectionDate(int classId, int sectionId, String date) async {
    // This method doesn't exist in our LocalDataSource
    // For now, return all attendance records
    return await getAttendanceByDate(date);
  }

  @override
  Future<void> saveAttendance(AttendanceEntity attendance) async {
    // Convert AttendanceEntity to AttendanceModel and save
    String classId = attendance.classId.toString();
    
    final model = AttendanceModel(
      id: attendance.id ?? 0,
      studentId: attendance.studentId,
      classId: classId,
      date: DateTime.parse(attendance.date),
      status: attendance.status,
      notes: null, // Not in entity
      createdAt: DateTime.parse(attendance.createdAt ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attendance.updatedAt ?? DateTime.now().toIso8601String()),
      synced: attendance.synced == 1,
    );
    
    await _localDataSource.insertAttendance(model);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    // For now, just save it again (replace)
    await saveAttendance(attendance);
  }

  @override
  Future<List<AttendanceEntity>> getUnsyncedAttendance() async {
    final attendanceModels = await _localDataSource.getUnsyncedAttendance();
    return attendanceModels.map((model) {
      // Convert String classId to int if possible
      int classIdAsInt;
      try {
        classIdAsInt = int.parse(model.classId);
      } catch (e) {
        classIdAsInt = 0; // Default to 0 if conversion fails
      }
      
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: classIdAsInt,
        sectionId: 0, // Not in our schema
        date: model.date.toIso8601String(),
        status: model.status,
        synced: model.synced ? 1 : 0,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<void> markAttendanceAsSynced(int attendanceId) async {
    await _localDataSource.updateAttendanceSyncStatus(attendanceId, true);
  }

  @override
  Future<void> clearLocalAttendance() async {
    await _localDataSource.clearAttendance();
  }
}