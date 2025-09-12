import 'dart:developer';

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
  // ignore: unused_field
  final ApiClient _apiClient; // will be used once data is no longer mocked
  AuthRemoteService(this._apiClient);

  /// Check authentication status (GET /auth/status)
  Future<Result<AuthStatusResponse, Exception>> getAuthStatus(
    String sessionToken,
  ) async {
    // Mock the auth status check
    log("Endpoint /auth/status called with token: $sessionToken");
    final result = AuthStatusResponse(isRegistered: true);

    return Future.delayed(Duration(seconds: 1), () => Result.success(result));
  }

  /// Exchange Google token with Laravel Sanctum token (login)
  /// Creates a stub user if doesn't exist, returns needsRegistration flag
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    log("Endpoint /auth/google/login called with token: $googleToken");

    // Mock response - in real implementation, server creates stub user if needed
    // and returns needsRegistration based on user completion status
    final result = LoginResponse(
      "session_token_example",
      true,
    ); // needsRegistration = true for demo

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));
  }

  /// Complete user registration using existing auth token
  /// Uses the token from login (no need for Google auth again)
  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    log("Endpoint /auth/register called with user data: ${userData.nome}");

    // Mock the submission - in real implementation, uses Authorization header
    // from ApiClient to complete the user registration
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
