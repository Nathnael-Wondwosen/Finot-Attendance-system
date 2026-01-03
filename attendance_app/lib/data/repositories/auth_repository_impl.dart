import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepositoryImpl();

  @override
  Future<bool> login(String email, String password) async {
    try {
      // For demo mode, we'll just return true
      // In a real implementation, you would call the actual API
      await _secureStorage.write(key: 'auth_token', value: 'demo_token');
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      await _secureStorage.write(
        key: 'user_data',
        value: '{"email": "$email", "name": "Demo User"}',
      );
      return true;
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
      await _secureStorage.write(
        key: 'user_data',
        value: _encodeMapToString(userData),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      return _decodeStringToMap(userData);
    }
    return null;
  }

  String _encodeMapToString(Map<String, dynamic> map) {
    // Simple implementation - in a real app you'd use proper JSON serialization
    return map.toString();
  }

  Map<String, dynamic> _decodeStringToMap(String str) {
    // Simple implementation - in a real app you'd use proper JSON parsing
    // For now, return a demo user data
    return {'email': 'demo@example.com', 'name': 'Demo User', 'role': 'admin'};
  }
}
