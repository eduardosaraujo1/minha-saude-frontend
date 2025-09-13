import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteService {
  // ignore: unused_field
  final ApiClient _apiClient; // will be used once data is no longer mocked

  // Mock control variables
  static const bool _mockLoginSuccess = true; // false = login error
  static const bool _mockUserIsRegistered =
      false; // true = user is already registered, false = needs registration
  static const int _mockRegisterResponse =
      0; // 0 = success, 1 = token expired error, 2 = generic error
  static const bool _mockLogoutSuccess = true; // false = logout error

  AuthRemoteService(this._apiClient);

  /// Exchange Google token for session token or register token (POST /auth/google/login)
  /// Returns: {is_registered,session_token?,register_token?,expires_at}
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    log("Endpoint /auth/google/login called with token: $googleToken");

    // Check if login should fail
    if (!_mockLoginSuccess) {
      return Future.delayed(
        Duration(seconds: 2),
        () => Result.error(Exception("Erro ao fazer login com Google")),
      );
    }

    // Mock response based on user registration status
    final LoginResponse result;
    if (_mockUserIsRegistered) {
      // User is already registered - return session token
      result = LoginResponse(
        isRegistered: true,
        sessionToken: "session_token_example",
        registerToken: null,
        expiresAt: DateTime.now().add(Duration(days: 30)),
      );
    } else {
      // User needs to complete registration - return register token
      result = LoginResponse(
        isRegistered: false,
        sessionToken: null,
        registerToken: "register_token_123",
        expiresAt: DateTime.now().add(Duration(minutes: 15)),
      );
    }

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));
  }

  /// Complete user registration using register token (POST /auth/google/register)
  /// Payload: {register_token,cpf,nome_completo,data_nascimento,telefone,codigo_telefone}
  /// Returns: {status,session_token,expires_at}
  Future<Result<RegisterResponse, Exception>> register(
    User userData,
    String registerToken,
  ) async {
    log(
      "Endpoint /auth/google/register called with user data: ${userData.nome} and register token: $registerToken",
    );

    // Mock response based on configuration
    switch (_mockRegisterResponse) {
      case 0: // Success
        final RegisterResponse result = RegisterResponse(
          RegisterStatus.success,
          sessionToken: "session_token_from_registration",
          expiresAt: DateTime.now().add(Duration(days: 30)),
        );
        return Future.delayed(
          Duration(seconds: 2),
          () => Result.success(result),
        );

      case 1: // Token expired error
        return Future.delayed(
          Duration(seconds: 2),
          () => Result.error(Exception("Token de registro expirado")),
        );

      case 2: // Generic error
        return Future.delayed(
          Duration(seconds: 2),
          () => Result.error(Exception("Erro ao registrar usuário")),
        );

      default: // Default to success
        final RegisterResponse result = RegisterResponse(
          RegisterStatus.success,
          sessionToken: "session_token_from_registration",
          expiresAt: DateTime.now().add(Duration(days: 30)),
        );
        return Future.delayed(
          Duration(seconds: 2),
          () => Result.success(result),
        );
    }
  }

  /// Logout user from server (POST /auth/logout)
  /// Invalidates the current session token
  Future<Result<void, Exception>> logout(String sessionToken) async {
    log("Endpoint /auth/logout called with token: $sessionToken");

    // Mock response based on configuration
    if (_mockLogoutSuccess) {
      return Future.delayed(Duration(seconds: 1), () => Result.success(null));
    } else {
      return Future.delayed(
        Duration(seconds: 1),
        () => Result.error(Exception("Erro ao fazer logout no servidor")),
      );
    }
  }
}
