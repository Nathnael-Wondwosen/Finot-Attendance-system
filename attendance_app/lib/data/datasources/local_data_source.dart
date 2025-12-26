import 'package:sqflite/sqflite.dart';
import '../../core/database_helper.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/section_model.dart';
import '../models/attendance_model.dart';
import '../models/sync_queue_model.dart';

class LocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Student methods
  Future<List<Student>> getStudents() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<void> saveStudents(List<Student> students) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete('students');
      for (var student in students) {
        await txn.insert('students', student.toMap());
      }
    });
  }

  Future<List<Student>> getStudentsByClassAndSection(int classId, int sectionId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'class_id = ? AND section_id = ?',
      whereArgs: [classId, sectionId],
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // Class methods
  Future<List<ClassModel>> getClasses() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<void> saveClasses(List<ClassModel> classes) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete('classes');
      for (var classModel in classes) {
        await txn.insert('classes', classModel.toMap());
      }
    });
  }

  // Section methods
  Future<List<SectionModel>> getSections() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sections');
    return List.generate(maps.length, (i) => SectionModel.fromMap(maps[i]));
  }

  Future<List<SectionModel>> getSectionsByClass(int classId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sections',
      where: 'class_id = ?',
      whereArgs: [classId],
    );
    return List.generate(maps.length, (i) => SectionModel.fromMap(maps[i]));
  }

  Future<void> saveSections(List<SectionModel> sections) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete('sections');
      for (var section in sections) {
        await txn.insert('sections', section.toMap());
      }
    });
  }

  // Attendance methods
  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_local',
      where: 'date = ?',
      whereArgs: [date],
    );
    return List.generate(maps.length, (i) => AttendanceModel.fromMap(maps[i]));
  }

  Future<List<AttendanceModel>> getAttendanceByClassSectionDate(int classId, int sectionId, String date) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_local',
      where: 'class_id = ? AND section_id = ? AND date = ?',
      whereArgs: [classId, sectionId, date],
    );
    return List.generate(maps.length, (i) => AttendanceModel.fromMap(maps[i]));
  }

  Future<void> saveAttendance(AttendanceModel attendance) async {
    final db = await _databaseHelper.database;
    
    // Check if attendance already exists for this student on this date
    final List<Map<String, dynamic>> existing = await db.query(
      'attendance_local',
      where: 'student_id = ? AND date = ?',
      whereArgs: [attendance.studentId, attendance.date],
    );

    if (existing.isNotEmpty) {
      // Update existing attendance
      await db.update(
        'attendance_local',
        attendance.toMap()..remove('id'),
        where: 'student_id = ? AND date = ?',
        whereArgs: [attendance.studentId, attendance.date],
      );
    } else {
      // Insert new attendance
      await db.insert('attendance_local', attendance.toMap());
    }
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    final db = await _databaseHelper.database;
    await db.update(
      'attendance_local',
      attendance.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<List<AttendanceModel>> getUnsyncedAttendance() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_local',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => AttendanceModel.fromMap(maps[i]));
  }

  Future<void> markAttendanceAsSynced(int attendanceId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'attendance_local',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [attendanceId],
    );
  }

  Future<void> clearLocalAttendance() async {
    final db = await _databaseHelper.database;
    await db.delete('attendance_local');
  }

  // Sync Queue methods
  Future<void> addToSyncQueue(String tableName, int recordId, String action, String data) async {
    final db = await _databaseHelper.database;
    final syncQueue = SyncQueueModel(
      tableName: tableName,
      recordId: recordId,
      action: action,
      data: data,
    );
    await db.insert('sync_queue', syncQueue.toMap());
  }

  Future<List<SyncQueueModel>> getUnsyncedItems() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => SyncQueueModel.fromMap(maps[i]));
  }

  Future<void> markSyncQueueItemAsSynced(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sync_queue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncQueue() async {
    final db = await _databaseHelper.database;
    await db.delete('sync_queue');
  }
}