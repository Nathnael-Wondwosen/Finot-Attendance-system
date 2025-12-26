import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<bool> execute(String email, String password) async {
    return await _authRepository.login(email, password);
  }
}

class LogoutUsecase {
  final AuthRepository _authRepository;

  LogoutUsecase(this._authRepository);

  Future<void> execute() async {
    await _authRepository.logout();
  }
}

class IsLoggedInUsecase {
  final AuthRepository _authRepository;

  IsLoggedInUsecase(this._authRepository);

  Future<bool> execute() async {
    return await _authRepository.isLoggedIn();
  }
}