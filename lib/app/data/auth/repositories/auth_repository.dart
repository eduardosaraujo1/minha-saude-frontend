import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepository {
  final AuthRemoteService _authRemoteService;
  final GoogleSignInService _googleSignInService;
  final TokenRepository _tokenRepository;

  // Temporary register token storage (short-lived, stored in Redis on backend)
  String? _registerToken;
  DateTime? _registerTokenExpiry;

  static Future<AuthRepository> create(
    AuthRemoteService authRemoteService,
    GoogleSignInService googleSignInService,
    TokenRepository tokenRepository,
  ) async {
    return AuthRepository._(
      authRemoteService,
      googleSignInService,
      tokenRepository,
    );
  }

  AuthRepository._(
    this._authRemoteService,
    this._googleSignInService,
    this._tokenRepository,
  );

  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  Future<Result<LoginResponse, Exception>> googleLogin() async {
    try {
      final authCode = await _getGoogleToken();
      if (authCode.isError()) {
        return Result.error(authCode.tryGetError()!);
      }
      final authToken = authCode.tryGetSuccess()!;

      // Exchange with backend for session token or register token
      final loginResponse = await _sendLoginRequest(authToken);
      if (loginResponse.isError()) {
        return Result.error(loginResponse.tryGetError()!);
      }
      final response = loginResponse.tryGetSuccess()!;

      // Handle the response based on registration status
      if (response.isRegistered) {
        // User is fully registered - store session token
        if (response.sessionToken != null) {
          await _tokenRepository.setToken(response.sessionToken!);
        }
        // Clear any existing register token
        _clearRegisterToken();
      } else {
        // User needs to complete registration - store register token
        if (response.registerToken != null) {
          _registerToken = response.registerToken;
          _registerTokenExpiry = response.expiresAt;
        }
        // Clear any existing session token
        await _tokenRepository.removeToken();
      }

      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o login: $e"));
    }
  }

  Future<Result<String, Exception>> _getGoogleToken() async {
    try {
      final googleSignInResult = await _googleSignInService
          .generateServerAuthCode();

      if (googleSignInResult.isError()) {
        return Result.error(
          Exception(
            "Não foi possível autenticar com o Google. Por favor, tente novamente.",
          ),
        );
      }
      final authCode = googleSignInResult.tryGetSuccess();

      if (authCode == null) {
        return Result.error(
          Exception("Código de autenticação do Google não foi obtido."),
        );
      }

      return Result.success(authCode);
    } catch (e) {
      return Result.error(
        Exception("Erro inesperado ao obter token do Google: $e"),
      );
    }
  }

  Future<Result<LoginResponse, Exception>> _sendLoginRequest(
    String googleToken,
  ) async {
    try {
      final response = await _authRemoteService.loginWithGoogle(googleToken);
      if (response.isError()) {
        return Result.error(
          Exception(
            "Não foi possível conectar ao servidor. Por favor, tente novamente mais tarde.",
          ),
        );
      }
      return Result.success(response.tryGetSuccess()!);
    } catch (e) {
      return Result.error(
        Exception("Erro inesperado ao trocar token do Google: $e"),
      );
    }
  }

  /// Complete user registration with provided user data
  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    try {
      // Check if we have a valid register token
      if (_registerToken == null || _isRegisterTokenExpired()) {
        return Result.error(
          Exception("Token de registro expirado. Faça login novamente."),
        );
      }

      // Use the register token to complete registration
      final registerResult = await _authRemoteService.register(
        userData,
        _registerToken!,
      );

      if (registerResult.isError()) {
        // Check if error is due to expired token
        final error = registerResult.tryGetError();
        if (error.toString().contains("token") ||
            error.toString().contains("expired")) {
          _clearRegisterToken();
          return Result.error(
            Exception("Token de registro expirou. Faça login novamente."),
          );
        }
        return Result.error(
          Exception(
            "Ocorreu um erro ao registrar. Verifique sua conexão com a internet",
          ),
        );
      }

      final response = registerResult.tryGetSuccess()!;

      // Registration successful - clear register token
      _clearRegisterToken();

      return Result.success(response);
    } catch (e) {
      log(e.toString());
      return Result.error(Exception("Ocorreu um erro desconhecido."));
    }
  }

  // =============================================================================
  // READ OPERATIONS (Registration status checks)
  // =============================================================================

  /// Check if user is registered based on current tokens
  Future<bool> isRegistered() async {
    // If we have a session token, user is registered
    if (_tokenRepository.hasToken) {
      return true;
    }

    // If we have a register token that's not expired, user is not registered
    if (_registerToken != null && !_isRegisterTokenExpired()) {
      return false;
    }

    // No valid tokens - user needs to login
    return false;
  }

  /// Check if user has a valid register token for completing registration
  bool get hasValidRegisterToken {
    return _registerToken != null && !_isRegisterTokenExpired();
  }

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  Future<Result<void, Exception>> signOut() async {
    try {
      final currentToken = _tokenRepository.token;

      // Clear all local state
      _clearRegisterToken();

      // If we had a session token, try to logout from server
      if (currentToken != null && currentToken.isNotEmpty) {
        final serverLogoutResult = await _authRemoteService.logout(
          currentToken,
        );

        // Note: We don't fail the whole logout if server logout fails
        // The user is considered logged out locally regardless
        if (serverLogoutResult.isError()) {
          log("Warning: Server logout failed, but user is logged out locally");
        }
      }

      // Clear session token
      await _tokenRepository.removeToken();

      return Result.success(null);
    } catch (e) {
      // Even if there's an error, ensure local session is cleared
      _clearRegisterToken();
      await _tokenRepository.removeToken();

      return Result.error(Exception("Erro durante logout: $e"));
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if token repository has been initialized
  bool get isTokenRepositoryInitialized => _tokenRepository.isInitialized;

  /// Clear register token and expiry
  void _clearRegisterToken() {
    _registerToken = null;
    _registerTokenExpiry = null;
  }

  /// Check if register token is expired
  bool _isRegisterTokenExpired() {
    if (_registerTokenExpiry == null) return true;
    return DateTime.now().isAfter(_registerTokenExpiry!);
  }

  /// Force clear all tokens and state - used for debugging/testing
  Future<void> clearAllState() async {
    _clearRegisterToken();
    await _tokenRepository.removeToken();
  }
}
