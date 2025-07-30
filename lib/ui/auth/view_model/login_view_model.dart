import 'package:minha_saude_frontend/data/services/google_auth_service.dart';
import 'package:minha_saude_frontend/utils/result.dart';

class LoginViewModel {
  LoginViewModel(GoogleAuthService authService) : _authService = authService;
  final GoogleAuthService _authService;

  Future<Result<String?>> signInWithGoogle() async {
    // TODO: return if should sign directly (redirect to home) or sign up (redirect to register)
    return _authService.generateServerAuthCode();
  }
}
