import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_service.dart';
import 'package:multiple_result/multiple_result.dart';

class LoginViewModel {
  const LoginViewModel(GoogleAuthService authService)
    : _authService = authService;
  final GoogleAuthService _authService;

  Future<Result<String?, Exception>> signInWithGoogle() async {
    // TODO: return if should sign directly (redirect to home) or sign up (redirect to register)
    return _authService.generateServerAuthCode();
  }
}
