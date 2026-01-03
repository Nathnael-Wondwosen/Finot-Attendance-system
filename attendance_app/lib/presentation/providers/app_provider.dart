import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/class_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../core/sync_service.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource();
});

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return ClassRepositoryImpl(localDataSource);
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return StudentRepositoryImpl(localDataSource);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  return AttendanceRepositoryImpl(localDataSource);
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final localDataSource = ref.watch(localDataSourceProvider);
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final classRepository = ref.watch(classRepositoryProvider);
  final studentRepository = ref.watch(studentRepositoryProvider);
  return SyncRepositoryImpl(
    localDataSource,
    remoteDataSource,
    classRepository,
    studentRepository,
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final syncRepository = ref.watch(syncRepositoryProvider);
  return SyncService(syncRepository);
});
