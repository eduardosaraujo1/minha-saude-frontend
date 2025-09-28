import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleLoginAction {
  GoogleLoginAction(AuthRepository authRepository)
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<Result<LoginResponse, Exception>> execute() async {
    final googleTokenResult = await _authRepository.getGoogleServerToken();

    if (googleTokenResult.isError()) {
      return Result.error(
        Exception("Não foi possível se autenticar com o Google"),
      );
    }

    final googleToken = googleTokenResult.getOrThrow();

    // Continue with the login process using the obtained token
    final loginResult = await _authRepository.loginWithGoogle(googleToken);

    if (loginResult.isError()) {
      return Result.error(
        Exception("Não foi possível fazer login com o Google"),
      );
    }

    return loginResult;
  }
}
