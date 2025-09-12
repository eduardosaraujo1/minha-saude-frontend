import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:multiple_result/multiple_result.dart';

/// Model for auth status response
class AuthStatusResponse {
  final bool isRegistered;

  AuthStatusResponse({required this.isRegistered});
}

class AuthRemoteService {
  final ApiClient _apiClient; // will be used once data is no longer mocked
  AuthRemoteService(this._apiClient);

  /// Check authentication status (GET /auth/status)
  Future<Result<AuthStatusResponse, Exception>> getAuthStatus(
    String sessionToken,
  ) async {
    // Mock the auth status check
    final result = AuthStatusResponse(isRegistered: true);

    return Future.delayed(Duration(seconds: 1), () => Result.success(result));
  }

  /// Exchange Google token with Laravel Sanctum token (login)
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    final result = LoginResponse("session_token_example", true);

    // Mock the submission to the backend, return a fake Laravel Sanctum token
    return Future.delayed(Duration(seconds: 2), () => Result.success(result));
  }

  /// Register with Google OAuth (POST /auth/google/register)
  Future<Result<RegisterResponse, Exception>> registerWithGoogle(
    User userData,
    String googleAuthCode,
  ) async {
    // Mock the submission to the backend, return a fake register response
    final RegisterResponse result = RegisterResponse(RegisterStatus.success);

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));
  }

  /// Legacy register method for backward compatibility
  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    // Mock the submission to the backend, return a fake register error or success
    final RegisterResponse result = RegisterResponse(RegisterStatus.success);

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));
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
