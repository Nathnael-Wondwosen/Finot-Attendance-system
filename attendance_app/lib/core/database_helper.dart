import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    // Delete the database file if it exists to force recreation with new schema
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id INTEGER,
        name TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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
      } catch (e) {
        // Column might already exist, ignore the error
        print('Column may also exist: $e');
      }
    }

    // If upgrading from version 1 or 2 to 3, recreate the students table with new schema
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

        // Re-insert the data with proper column mapping (this will work if we're going from old to new schema)
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

  Future<void> clearDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('students');
      await txn.delete('classes');
      await txn.delete('sections');
      await txn.delete('attendance_records');
      await txn.delete('sync_queue');
    });
  }
}
