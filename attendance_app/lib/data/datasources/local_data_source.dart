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
      version: 3, // Incremented version to trigger onUpgrade
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // If upgrading from version 1 to 2, add the class_name column to attendance_records
    if (oldVersion < 2 && newVersion >= 2) {
      try {
        // Check if class_name column exists before adding it
        await db.execute(
          'ALTER TABLE attendance_records ADD COLUMN class_name TEXT;',
        );
        await db.execute(
          'ALTER TABLE attendance_records ADD COLUMN notes TEXT;',
        );
        await db.execute(
          'ALTER TABLE attendance_records ADD COLUMN section_id INTEGER NOT NULL DEFAULT 0;',
        );
      } catch (e) {
        // Column might already exist, ignore the error
        print('Column may already exist: $e');
      }
    }

    // If upgrading from version 1, 2 to 3, recreate the students table with new schema
    if (oldVersion < 3 && newVersion >= 3) {
      try {
        // Since we changed the students table schema, we need to recreate it
        // First, copy the existing data
        final List<Map<String, dynamic>> existingStudents = await db.query(
          'students',
        );

        // Drop the old table
        await db.execute('DROP TABLE students;');

        // Create the new table with the updated schema
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            full_name TEXT NOT NULL,
            gender TEXT,
            birth_date TEXT,
            current_grade TEXT,
            father_phone TEXT,
            mother_phone TEXT,
            phone_number TEXT,
            has_spiritual_father TEXT,
            class_id INTEGER,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Re-insert the data with proper column mapping
        for (final student in existingStudents) {
          await db.insert('students', {
            'id': student['id'],
            'server_id': student['server_id'],
            'full_name': student['name'] ?? student['full_name'] ?? '',
            'gender': student['gender'],
            'birth_date': student['birth_date'],
            'current_grade': student['current_grade'],
            'father_phone': student['father_phone'],
            'mother_phone': student['mother_phone'],
            'phone_number': student['phone_number'],
            'has_spiritual_father': student['has_spiritual_father'],
            'class_id': student['class_id'],
            'created_at': student['created_at'],
            'updated_at': student['updated_at'],
          });
        }
      } catch (e) {
        print('Error during schema upgrade: $e');
        // If the upgrade fails, create the new schema anyway
        try {
          await db.execute('DROP TABLE IF EXISTS students;');
          await db.execute('''
            CREATE TABLE students (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              server_id INTEGER,
              full_name TEXT NOT NULL,
              gender TEXT,
              birth_date TEXT,
              current_grade TEXT,
              father_phone TEXT,
              mother_phone TEXT,
              phone_number TEXT,
              has_spiritual_father TEXT,
              class_id INTEGER,
              created_at TEXT,
              updated_at TEXT
            )
          ''');
        } catch (createError) {
          print('Error creating new students table: $createError');
        }
      }
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        full_name TEXT NOT NULL,
        gender TEXT,
        birth_date TEXT,
        current_grade TEXT,
        father_phone TEXT,
        mother_phone TEXT,
        phone_number TEXT,
        has_spiritual_father TEXT,
        class_id INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create classes table
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create sections table
    await db.execute('''
      CREATE TABLE sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        class_id INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create attendance records table
    await db.execute('''
      CREATE TABLE attendance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        class_id INTEGER NOT NULL,
        class_name TEXT,
        section_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'present', -- present, absent, late
        notes TEXT,
        synced INTEGER DEFAULT 0, -- 0 = not synced, 1 = synced
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL, -- insert, update, delete
        data TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Classes operations
  Future<int> insertClass(ClassModel classModel) async {
    final db = await database;
    return await db.insert(
      'classes',
      classModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClassModel>> getClasses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');

    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }

  Future<ClassModel?> getClassById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
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

  Future<List<StudentModel>> getStudentsByClass(int classId) async {
    final db = await database;
    // Query students by class_id
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'class_id = ?',
      whereArgs: [classId],
    );

    final result = List.generate(maps.length, (i) {
      return StudentModel.fromMap(maps[i]);
    });

    print(
      'LocalDataSource: Found ${result.length} students for class ID: $classId',
    );
    print('LocalDataSource: Query parameters - class_id = $classId');

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

  Future<List<AttendanceModel>> getAttendanceByClass(int classId) async {
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

  Future<List<AttendanceModel>> getAttendanceByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'date = ?',
      whereArgs: [date],
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<List<AttendanceModel>> getAttendanceByClassIdAndDate(
    int classId,
    String date,
  ) async {
    // Extract just the date part (YYYY-MM-DD) from the date string for comparison
    final dateOnly = date.split('T')[0];
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'class_id = ? AND date LIKE ?',
      whereArgs: [classId, '$dateOnly%'],
    );

    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<int> updateAttendance(AttendanceModel attendanceModel) async {
    final db = await database;
    return await db.update(
      'attendance_records',
      attendanceModel.toMap(),
      where: 'id = ?',
      whereArgs: [attendanceModel.id],
    );
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
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
    await db.delete('classes');
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
