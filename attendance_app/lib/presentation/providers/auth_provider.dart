import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // This will be implemented in app_provider.dart
  throw UnimplementedError();
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.read(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.read(authRepositoryProvider));
});

final isLoggedInUsecaseProvider = Provider<IsLoggedInUsecase>((ref) {
  return IsLoggedInUsecase(ref.read(authRepositoryProvider));
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref.read(isLoggedInUsecaseProvider), ref);
});

class AuthStateNotifier extends StateNotifier<bool> {
  final IsLoggedInUsecase _isLoggedInUsecase;
  final Ref _ref;

  AuthStateNotifier(this._isLoggedInUsecase, this._ref) : super(false) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _isLoggedInUsecase.execute();
    state = isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    final success = await _isLoggedInUsecase.execute();
    if (success) {
      state = true;
    }
    return success;
  }

  Future<void> logout() async {
    await _ref.read(logoutUsecaseProvider).execute();
    state = false;
  }
}