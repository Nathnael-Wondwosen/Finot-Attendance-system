abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAuthToken();
  Future<void> setAuthToken(String token);
  Future<bool> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
}