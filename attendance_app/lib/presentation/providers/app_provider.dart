import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../data/repositories/class_repository_impl.dart';
import '../../data/repositories/section_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/class_repository.dart';
import '../../domain/repositories/section_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../providers/theme_provider.dart';
import '../../core/sync_service.dart';

// This is a basic provider that will be used to initialize our repositories
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource();
});

// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final syncRepository = ref.read(syncRepositoryProvider);
  final classRepository = ref.read(classRepositoryProvider);
  final studentRepository = ref.read(studentRepositoryProvider);
  final attendanceRepository = ref.read(attendanceRepositoryProvider);
  return SyncService(syncRepository, classRepository, studentRepository, attendanceRepository);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final localDataSource = ref.read(localDataSourceProvider);
  return StudentRepositoryImpl(localDataSource);
});

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final localDataSource = ref.read(localDataSourceProvider);
  return ClassRepositoryImpl(localDataSource);
});

final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  final localDataSource = ref.read(localDataSourceProvider);
  return SectionRepositoryImpl(localDataSource);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final localDataSource = ref.read(localDataSourceProvider);
  return AttendanceRepositoryImpl(localDataSource);
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final localDataSource = ref.read(localDataSourceProvider);
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final classRepository = ref.read(classRepositoryProvider);
  final studentRepository = ref.read(studentRepositoryProvider);
  return SyncRepositoryImpl(localDataSource, remoteDataSource, classRepository, studentRepository);
});