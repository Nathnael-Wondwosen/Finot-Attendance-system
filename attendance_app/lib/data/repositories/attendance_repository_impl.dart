import '../datasources/local_data_source.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalDataSource _localDataSource;

  AttendanceRepositoryImpl(this._localDataSource);

  @override
  Future<List<AttendanceEntity>> getAttendanceByDate(String date) async {
    final attendanceModels = await _localDataSource.getAttendanceByDate(date);
    return attendanceModels.map((model) {
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: model.classId,
        className: model.className,
        sectionId: model.sectionId,
        date: model.date.toIso8601String(),
        status: model.status,
        synced: model.synced ? 1 : 0,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByClassSectionDate(
    int classId,
    int sectionId,
    String date,
  ) async {
    final attendanceModels = await _localDataSource
        .getAttendanceByClassIdAndDate(classId, date);
    return attendanceModels.map((model) {
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: model.classId,
        className: model.className,
        sectionId: model.sectionId,
        date: model.date.toIso8601String(),
        status: model.status,
        synced: model.synced ? 1 : 0,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<void> saveAttendance(AttendanceEntity attendance) async {
    // Convert AttendanceEntity to AttendanceModel and save
    final model = AttendanceModel(
      id: attendance.id ?? 0,
      studentId: attendance.studentId,
      classId: attendance.classId,
      className: attendance.className,
      sectionId: attendance.sectionId,
      date: DateTime.parse(attendance.date),
      status: attendance.status,
      notes: null, // Not in entity
      createdAt:
          attendance.createdAt != null
              ? DateTime.parse(attendance.createdAt!)
              : DateTime.now(),
      updatedAt:
          attendance.updatedAt != null
              ? DateTime.parse(attendance.updatedAt!)
              : DateTime.now(),
      synced: attendance.synced == 1,
    );

    await _localDataSource.insertAttendance(model);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    // Convert AttendanceEntity to AttendanceModel and update
    final model = AttendanceModel(
      id: attendance.id ?? 0,
      studentId: attendance.studentId,
      classId: attendance.classId,
      className: attendance.className,
      sectionId: attendance.sectionId,
      date: DateTime.parse(attendance.date),
      status: attendance.status,
      notes: null, // Not in entity
      createdAt:
          attendance.createdAt != null
              ? DateTime.parse(attendance.createdAt!)
              : DateTime.now(),
      updatedAt:
          attendance.updatedAt != null
              ? DateTime.parse(attendance.updatedAt!)
              : DateTime.now(),
      synced: attendance.synced == 1,
    );

    await _localDataSource.updateAttendance(model);
  }

  @override
  Future<List<AttendanceEntity>> getUnsyncedAttendance() async {
    final attendanceModels = await _localDataSource.getUnsyncedAttendance();
    return attendanceModels.map((model) {
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: model.classId,
        className: model.className,
        sectionId: model.sectionId,
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
  Future<List<AttendanceEntity>> getAllAttendance() async {
    final attendanceModels = await _localDataSource.getAllAttendance();
    return attendanceModels.map((model) {
      return AttendanceEntity(
        id: model.id,
        studentId: model.studentId,
        classId: model.classId,
        className: model.className,
        sectionId: model.sectionId,
        date: model.date.toIso8601String(),
        status: model.status,
        synced: model.synced ? 1 : 0,
        createdAt: model.createdAt.toIso8601String(),
        updatedAt: model.updatedAt.toIso8601String(),
      );
    }).toList();
  }

  @override
  Future<void> clearLocalAttendance() async {
    await _localDataSource.clearAttendance();
  }
}
