import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteService {
  final ApiClient _apiClient; // will be used once data is no longer mocked
  AuthRemoteService(this._apiClient);

  /// Exchange Google token with Laravel Sanctum token (login)
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    // Mock the submission to the backend, return a fake Laravel Sanctum token
    return Future.delayed(
      Duration(seconds: 2),
      // () => Result.success(AuthResponse("session_token_example", false)),
      () => Result.success(LoginResponse("session_token_example", true)),
      // () => Result.error(Exception("Erro ao autenticar com o Google")),
    );
  }

  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    // Mock the submission to the backend, return a fake register error or success
    return Future.delayed(
      Duration(seconds: 2),
      () => Result.success(RegisterResponse(RegisterStatus.success)),
      // () => Result.error(Exception("Erro ao autenticar com o Google")),
    );
  }

  /// Logout user from server (invalidate session token)
  Future<Result<void, Exception>> logout(String sessionToken) async {
    // Mock the logout request to the backend
    return Future.delayed(
      Duration(seconds: 1),
      () => Result.success(null),
      // () => Result.error(Exception("Erro ao fazer logout no servidor")),
    );
  }
}
