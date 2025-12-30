import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';

class LocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(
      path,
      version: 2, // Incremented version to trigger onUpgrade
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrade from version 1 to 2
    if (oldVersion < 2) {
      // Add class_id column to students table
      await db.execute('ALTER TABLE students ADD COLUMN class_id INTEGER');
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create classes table
    await db.execute('''
      CREATE TABLE attendance_classes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacher_name TEXT,
        academic_year INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        full_name TEXT NOT NULL,
        gender TEXT,
        birth_date TEXT,
        current_grade TEXT,
        father_phone TEXT,
        mother_phone TEXT,
        phone_number TEXT,
        has_spiritual_father TEXT,
        class_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create attendance records table
    await db.execute('''
      CREATE TABLE attendance_records (
        id INTEGER PRIMARY KEY,
        student_id INTEGER NOT NULL,
        class_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (class_id) REFERENCES attendance_classes (id)
      )
    ''');
  }

  // Classes operations
  Future<int> insertClass(ClassModel classModel) async {
    final db = await database;
    return await db.insert(
      'attendance_classes',
      classModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClassModel>> getClasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_classes',
    );

    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }

  Future<ClassModel?> getClassById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_classes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ClassModel.fromMap(maps.first);
    }
    return null;
  }

  // Students operations
  Future<int> insertStudent(StudentModel studentModel) async {
    final db = await database;
    return await db.insert(
      'students',
      studentModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertStudents(List<StudentModel> students) async {
    final db = await database;
    int count = 0;

    await db.transaction((txn) async {
      for (final student in students) {
        await txn.insert(
          'students',
          student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    });

    return count;
  }

  Future<List<StudentModel>> getStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');

    final result = List.generate(maps.length, (i) {
      return StudentModel.fromMap(maps[i]);
    });

    print(
      'LocalDataSource: Retrieved ${result.length} total students from database',
    );
    return result;
  }

  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    final db = await database;
    // Query students by class_id
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'class_id = ?',
      whereArgs: [int.tryParse(classId)],
    );

    final result = List.generate(maps.length, (i) {
      return StudentModel.fromMap(maps[i]);
    });

    print(
      'LocalDataSource: Found ${result.length} students for class ID: $classId',
    );
    print(
      'LocalDataSource: Query parameters - class_id = ${int.tryParse(classId)}',
    );

    // Debug: Let's also check what values exist in the class_id column
    final allClassIds = await db.rawQuery(
      'SELECT DISTINCT class_id FROM students WHERE class_id IS NOT NULL',
    );
    print(
      'LocalDataSource: Available class_ids in database: ${allClassIds.map((row) => row['class_id']).toList()}',
    );

    return result;
  }

  // Attendance operations
  Future<int> insertAttendance(AttendanceModel attendanceModel) async {
    final db = await database;
    return await db.insert(
      'attendance_records',
      attendanceModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAttendanceSyncStatus(int id, bool synced) async {
    final db = await database;
    return await db.update(
      'attendance_records',
      {'synced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<AttendanceModel>> getUnsyncedAttendance() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'synced = ?',
      whereArgs: [0], // 0 means not synced
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceModel>> getAttendanceByClass(String classId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'class_id = ?',
      whereArgs: [classId],
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceModel>> getAttendanceByStudent(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  // Clear all data (for sync purposes)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('attendance_records');
    await db.delete('students');
    await db.delete('attendance_classes');
  }

  // Clear attendance records (for refresh)
  Future<void> clearAttendance() async {
    final db = await database;
    await db.delete('attendance_records');
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }
}
