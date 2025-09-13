import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/shared/services/api_client.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRemoteService {
  // ignore: unused_field
  final ApiClient _apiClient; // will be used once data is no longer mocked
  AuthRemoteService(this._apiClient);

  /// Exchange Google token for session token or register token (POST /auth/google/login)
  /// Returns: {is_registered,session_token?,register_token?,expires_at}
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleToken,
  ) async {
    log("Endpoint /auth/google/login called with token: $googleToken");

    // Mock response for testing - simulate unregistered user needing to complete registration
    final result = LoginResponse(
      isRegistered: false, // User needs to complete registration
      sessionToken: null, // No session token yet
      registerToken: "register_token_123", // Short-lived token for registration
      expiresAt: DateTime.now().add(Duration(minutes: 15)), // 15 minute expiry
    );

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));

    // TODO: For registered users, return:
    // final result = LoginResponse(
    //   isRegistered: true,
    //   sessionToken: "session_token_example",
    //   registerToken: null,
    //   expiresAt: DateTime.now().add(Duration(days: 30)),
    // );

    // TODO: Error handling
    // return Future.delayed(
    //   Duration(seconds: 2),
    //   () => Result.error(Exception("Erro ao fazer login com Google")),
    // );
  }

  /// Complete user registration using register token (POST /auth/google/register)
  /// Payload: {register_token,cpf,nome_completo,data_nascimento,telefone,codigo_telefone}
  /// Returns: {status,expires_at}
  Future<Result<RegisterResponse, Exception>> register(
    User userData,
    String registerToken,
  ) async {
    log(
      "Endpoint /auth/google/register called with user data: ${userData.nome} and register token: $registerToken",
    );

    // Mock the submission - in real implementation, uses register_token
    // to complete the user registration
    final RegisterResponse result = RegisterResponse(RegisterStatus.success);

    return Future.delayed(Duration(seconds: 2), () => Result.success(result));

    // TODO: Error handling for expired token
    // return Future.delayed(
    //   Duration(seconds: 2),
    //   () => Result.error(Exception("Token de registro expirado")),
    // );
  }

  /// Logout user from server (POST /auth/logout)
  /// Invalidates the current session token
  Future<Result<void, Exception>> logout(String sessionToken) async {
    log("Endpoint /auth/logout called with token: $sessionToken");

    // Mock the logout request to the backend
    return Future.delayed(
      Duration(seconds: 1),
      () => Result.success(null),
      // () => Result.error(Exception("Erro ao fazer logout no servidor")),
    );
  }
}
