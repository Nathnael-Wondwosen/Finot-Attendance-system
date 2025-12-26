import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local_data_source.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalDataSource _localDataSource;

  AttendanceRepositoryImpl(this._localDataSource);

  @override
  Future<List<AttendanceEntity>> getAttendanceByDate(String date) async {
    final attendance = await _localDataSource.getAttendanceByDate(date);
    return attendance.map((model) => AttendanceEntity(
      id: model.id,
      studentId: model.studentId,
      classId: model.classId,
      sectionId: model.sectionId,
      date: model.date,
      status: model.status,
      synced: model.synced,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByClassSectionDate(int classId, int sectionId, String date) async {
    final attendance = await _localDataSource.getAttendanceByClassSectionDate(classId, sectionId, date);
    return attendance.map((model) => AttendanceEntity(
      id: model.id,
      studentId: model.studentId,
      classId: model.classId,
      sectionId: model.sectionId,
      date: model.date,
      status: model.status,
      synced: model.synced,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<void> saveAttendance(AttendanceEntity attendance) async {
    final model = AttendanceModel(
      id: attendance.id,
      studentId: attendance.studentId,
      classId: attendance.classId,
      sectionId: attendance.sectionId,
      date: attendance.date,
      status: attendance.status,
      synced: attendance.synced,
      createdAt: attendance.createdAt,
      updatedAt: attendance.updatedAt,
    );
    await _localDataSource.saveAttendance(model);
  }

  @override
  Future<void> updateAttendance(AttendanceEntity attendance) async {
    final model = AttendanceModel(
      id: attendance.id,
      studentId: attendance.studentId,
      classId: attendance.classId,
      sectionId: attendance.sectionId,
      date: attendance.date,
      status: attendance.status,
      synced: attendance.synced,
      createdAt: attendance.createdAt,
      updatedAt: attendance.updatedAt,
    );
    await _localDataSource.updateAttendance(model);
  }

  @override
  Future<List<AttendanceEntity>> getUnsyncedAttendance() async {
    final attendance = await _localDataSource.getUnsyncedAttendance();
    return attendance.map((model) => AttendanceEntity(
      id: model.id,
      studentId: model.studentId,
      classId: model.classId,
      sectionId: model.sectionId,
      date: model.date,
      status: model.status,
      synced: model.synced,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    )).toList();
  }

  @override
  Future<void> markAttendanceAsSynced(int attendanceId) async {
    await _localDataSource.markAttendanceAsSynced(attendanceId);
  }

  @override
  Future<void> clearLocalAttendance() async {
    await _localDataSource.clearLocalAttendance();
  }
}