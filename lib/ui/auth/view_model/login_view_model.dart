import 'package:minha_saude_frontend/data/services/google_auth_service.dart';
import 'package:minha_saude_frontend/utils/result.dart';

class LoginViewModel {
  LoginViewModel(GoogleAuthService authService) : _authService = authService;
  final GoogleAuthService _authService;

  Future<Result<String?>> getAuthCode() async {
    return _authService.generateServerAuthCode();
  }
}
