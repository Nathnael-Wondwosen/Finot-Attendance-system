import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/attendance_model.dart';

class SyncRepositoryImpl implements SyncRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final ClassRepository _classRepository;
  final StudentRepository _studentRepository;

  SyncRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._classRepository,
    this._studentRepository,
  );

  @override
  Future<void> syncData() async {
    try {
      // First upload anything pending, then refresh the local cache
      await uploadAttendanceData();
      await downloadAllClasses();
    } catch (e) {
      print('Error syncing data: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasInternetConnection() async {
    try {
      return await _remoteDataSource.testConnection();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    final pending = await _localDataSource.getUnsyncedAttendance();
    return pending.length;
  }

  @override
  Future<bool> downloadClassData(String classId) async {
    try {
      // Convert classId to int for the API call
      final intClassId = int.tryParse(classId) ?? 0;
      print('Downloading data for class ID: $intClassId');

      // Get students for this class from remote using the proper endpoint
      final remoteStudents = await _remoteDataSource.fetchStudentsByClass(
        intClassId,
      );

      print(
        'Fetched ${remoteStudents.length} students from remote for class $intClassId',
      );

      // Save students to local storage
      if (remoteStudents.isNotEmpty) {
        await _studentRepository.saveStudents(remoteStudents);
        print(
          'Saved ${remoteStudents.length} students to local storage for class $intClassId',
        );
      } else {
        print('No students fetched for class $intClassId, not saving any data');
      }

      return true;
    } catch (e) {
      print('Error downloading class data: $e');
      return false;
    }
  }

  @override
  Future<bool> downloadAllClasses() async {
    try {
      // Get all classes from remote
      final remoteClasses = await _remoteDataSource.fetchClasses();
      print('Fetched ${remoteClasses.length} classes from remote');

      // Save classes to local storage
      await _classRepository.saveClasses(remoteClasses);

      // For each class, get its specific students
      for (final classEntity in remoteClasses) {
        try {
          print(
            'Fetching students for class ${classEntity.name} (ID: ${classEntity.serverId})',
          );

          // Fetch students specifically for this class
          final remoteStudents = await _remoteDataSource.fetchStudentsByClass(
            classEntity.serverId ?? 0,
          );

          print(
            'Fetched ${remoteStudents.length} students for class ${classEntity.name}',
          );

          if (remoteStudents.isNotEmpty) {
            // Update the students to have the correct classId before saving
            final studentsWithClassId =
                remoteStudents
                    .map(
                      (student) => StudentEntity(
                        id: student.id,
                        serverId: student.serverId,
                        name: student.name,
                        christianName: student.christianName,
                        gender: student.gender,
                        currentGrade: student.currentGrade,
                        photoPath: student.photoPath,
                        phoneNumber: student.phoneNumber,
                        fatherFullName: student.fatherFullName,
                        fatherPhone: student.fatherPhone,
                        motherFullName: student.motherFullName,
                        motherPhone: student.motherPhone,
                        guardianFullName: student.guardianFullName,
                        guardianPhone: student.guardianPhone,
                        sourceType: student.sourceType,
                        rollNumber: student.rollNumber,
                        classId:
                            classEntity.serverId ??
                            0, // Set the correct classId
                        sectionId: student.sectionId,
                        createdAt: student.createdAt,
                        updatedAt: student.updatedAt,
                      ),
                    )
                    .toList();

            await _studentRepository.saveStudents(studentsWithClassId);
            print(
              'Saved ${studentsWithClassId.length} students for class ${classEntity.name}',
            );
          } else {
            print('No students found for class ${classEntity.name}');
          }
        } catch (e) {
          print('Error downloading students for class ${classEntity.name}: $e');
          // Continue with other classes even if one fails
        }
      }

      return true;
    } catch (e) {
      print('Error downloading all classes: $e');
      return false;
    }
  }

  @override
  Future<bool> uploadAttendanceData() async {
    try {
      final List<AttendanceModel> pending =
          await _localDataSource.getUnsyncedAttendance();

      if (pending.isEmpty) {
        print('SyncRepositoryImpl: No pending attendance to upload');
        return true;
      }

      final payload = pending
          .map((record) => {
                'local_id': record.id,
                'student_id': record.studentId,
                'class_id': record.classId,
                'section_id': record.sectionId,
                'status': record.status,
                'date': record.date.toIso8601String(),
                'notes': record.notes,
              })
          .toList();

      final success = await _remoteDataSource.submitAttendance(payload);

      if (success) {
        for (final record in pending) {
          await _localDataSource.updateAttendanceSyncStatus(record.id, true);
        }
        print('SyncRepositoryImpl: Uploaded and marked '
            '${pending.length} attendance records as synced');
      } else {
        print('SyncRepositoryImpl: Remote refused attendance upload');
      }

      return success;
    } catch (e) {
      print('Error uploading attendance data: $e');
      return false;
    }
  }

  @override
  Future<bool> isOnline() async {
    try {
      return await _remoteDataSource.testConnection();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearLocalData() async {
    try {
      await _localDataSource.clearAllData();
    } catch (e) {
      print('Error clearing local data: $e');
      rethrow;
    }
  }
}
