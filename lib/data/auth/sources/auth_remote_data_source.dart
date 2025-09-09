import 'package:minha_saude_frontend/domain/shared/models/user.dart';
import 'package:minha_saude_frontend/data/auth/DTO/auth_response.dart';
import 'package:minha_saude_frontend/data/auth/DTO/register_response.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource();

  /// Exchange Google token with Laravel Sanctum token (login)
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    // Mock the submition to the backend, return a fake Laravel Sanctum token
    return Future.delayed(
      Duration(seconds: 2),
      // () => Result.success(AuthResponse("session_token_example", false)),
      () => Result.success(LoginResponse("session_token_example", true)),
      // () => Result.error(Exception("Erro ao autenticar com o Google")),
    );
  }

  Future<Result<RegisterResponse, Exception>> registerWithGoogle(
    User userData,
  ) async {
    // Mock the submition to the backend, return a fake register error or success
    return Future.delayed(
      Duration(seconds: 2),
      () => Result.success(RegisterResponse(RegisterStatus.success, userData)),
      // () => Result.error(Exception("Erro ao autenticar com o Google")),
    );
  }
}
