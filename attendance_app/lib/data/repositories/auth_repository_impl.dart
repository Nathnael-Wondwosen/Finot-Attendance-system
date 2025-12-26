import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      if (response['token'] != null) {
        await _secureStorage.write(key: 'auth_token', value: response['token']);
        await _secureStorage.write(key: 'is_logged_in', value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.write(key: 'is_logged_in', value: 'false');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final isLoggedIn = await _secureStorage.read(key: 'is_logged_in');
    return token != null && isLoggedIn == 'true';
  }

  @override
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'is_logged_in', value: 'true');
  }

  @override
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _secureStorage.write(key: 'user_data', value: userData.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      // This is a simplified approach - in a real app, you'd want to properly serialize/deserialize
      return {'data': userData};
    }
    return null;
  }
}