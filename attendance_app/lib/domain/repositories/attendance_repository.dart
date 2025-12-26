import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendanceByDate(String date);
  Future<List<AttendanceEntity>> getAttendanceByClassSectionDate(int classId, int sectionId, String date);
  Future<void> saveAttendance(AttendanceEntity attendance);
  Future<void> updateAttendance(AttendanceEntity attendance);
  Future<List<AttendanceEntity>> getUnsyncedAttendance();
  Future<void> markAttendanceAsSynced(int attendanceId);
  Future<void> clearLocalAttendance();
}