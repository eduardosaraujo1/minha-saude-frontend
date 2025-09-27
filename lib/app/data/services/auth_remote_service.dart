import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/app/data/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/models/user_register_data.dart';
import 'package:minha_saude_frontend/app/data/services/api_client.dart';
import 'package:minha_saude_frontend/config/mock_endpoint_config.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteService {
  // ignore: unused_field
  final ApiClient _apiClient; // will be used once data is no longer mocked
  final mock = GetIt.I<MockEndpointConfig>();

  AuthRemoteService(this._apiClient);

  /// Exchange Google token for session token or register token (POST /auth/google/login)
  /// Returns: {is_registered,session_token?,register_token?,expires_at}
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    log("Endpoint /auth/google/login called with token: $googleToken");

    // Check if login should fail
    if (mock.serverAuthMode == ServerAuthMode.mockLoginError) {
      return Future.delayed(
        Duration(seconds: 2),
        () => Result.error(Exception("Erro ao fazer login com Google")),
      );
    }

    // Mock response based on user registration status
    final LoginResponse result;
    if (mock.serverAuthMode == ServerAuthMode.mockExistingUser) {
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
    UserRegisterData userData,
    String registerToken,
  ) async {
    log(
      "Endpoint /auth/google/register called with user data: ${userData.nome} and register token: $registerToken",
    );

    // Mock response based on configuration
    switch (mock.serverAuthMode) {
      case ServerAuthMode.mockNewUser: // Success
        final RegisterResponse result = RegisterResponse(
          RegisterStatus.success,
          sessionToken: "session_token_from_registration",
          expiresAt: DateTime.now().add(Duration(days: 30)),
        );
        return Future.delayed(
          Duration(seconds: 1),
          () => Result.success(result),
        );

      case ServerAuthMode.mockRegisterError: // Token expired error
        return Future.delayed(
          Duration(seconds: 1),
          () => Result.error(Exception("Erro ao registrar usuário")),
        );

      default: // Default to success
        final RegisterResponse result = RegisterResponse(
          RegisterStatus.success,
          sessionToken: "session_token_from_registration",
          expiresAt: DateTime.now().add(Duration(days: 30)),
        );
        return Future.delayed(
          Duration(seconds: 1),
          () => Result.success(result),
        );
    }
  }

  /// Logout user from server (POST /auth/logout)
  /// Invalidates the current session token
  Future<Result<void, Exception>> logout(String sessionToken) async {
    log("Endpoint /auth/logout called with token: $sessionToken");

    return Future.delayed(Duration(seconds: 1), () => Result.success(null));
  }
}
