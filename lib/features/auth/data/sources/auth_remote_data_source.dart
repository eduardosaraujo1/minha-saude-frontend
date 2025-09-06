import 'package:minha_saude_frontend/features/auth/data/models/auth_response.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource();

  /// Exchange Google token with Laravel Sanctum token (login)
  Future<Result<AuthResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    // Mock the submition to the backend, return a fake Laravel Sanctum token
    return Future.delayed(
      Duration(seconds: 2),
      // () => Result.success(AuthResponse("session_token_example", false)),
      () => Result.success(AuthResponse("session_token_example", true)),
      // () => Result.error(Exception("Erro ao autenticar com o Google")),
    );
  }
}
