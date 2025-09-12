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

  // Internal registration status storage
  bool _isRegistered = false;

  static Future<AuthRepository> create(
    AuthRemoteService authRemoteService,
    GoogleSignInService googleSignInService,
    TokenRepository tokenRepository,
  ) async {
    final repository = AuthRepository._(
      authRemoteService,
      googleSignInService,
      tokenRepository,
    );

    // Check registration status with server if we have a token
    await repository._loadRegistrationStatus();

    return repository;
  }

  AuthRepository._(
    this._authRemoteService,
    this._googleSignInService,
    this._tokenRepository,
  );

  /// Check registration status with server if we have a token
  Future<void> _loadRegistrationStatus() async {
    try {
      if (_tokenRepository.hasToken) {
        final statusResult = await _authRemoteService.getAuthStatus(
          _tokenRepository.token!,
        );
        if (statusResult.isSuccess()) {
          final status = statusResult.tryGetSuccess();
          _isRegistered = status?.isRegistered ?? false;
        }
      } else {
        _isRegistered = false;
      }
    } catch (e) {
      log("Error syncing registration status: $e");
    }
  }

  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  Future<Result<LoginResponse, Exception>> googleLogin() async {
    try {
      // Get Google auth code
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

      // Exchange with backend for session token
      final loginResponse = await _authRemoteService.loginWithGoogle(authCode);

      if (loginResponse.isError()) {
        return Result.error(
          Exception(
            "Não foi possível conectar ao servidor. Por favor, tente novamente mais tarde.",
          ),
        );
      }

      final response = loginResponse.tryGetSuccess()!;

      // Set registration status based on needsRegistration flag
      // Note: Token management is now handled by ViewModels
      _isRegistered = !response.isRegistered;

      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o login: $e"));
    }
  }

  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    try {
      // Check if user has a valid token
      if (!_tokenRepository.hasToken) {
        return Result.error(
          Exception(
            "Token de autenticação não encontrado. Faça login novamente.",
          ),
        );
      }

      // Use the existing token to complete registration
      final registerResult = await _authRemoteService.register(userData);

      if (registerResult.isError()) {
        return Result.error(
          Exception(
            "Ocorreu um erro ao registrar. Verifique sua conexão com a internet",
          ),
        );
      }

      final response = registerResult.tryGetSuccess()!;

      // Update registration status - user is now fully registered
      _isRegistered = true;

      return Result.success(response);
    } catch (e) {
      log(e.toString());
      return Result.error(Exception("Ocorreu um erro desconhecido."));
    }
  }

  // =============================================================================
  // READ OPERATIONS (Registration status checks only)
  // =============================================================================

  bool get isRegistered {
    return _isRegistered;
  }

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  Future<Result<void, Exception>> signOut() async {
    try {
      final currentToken = _tokenRepository.token;

      // Clear local registration state
      _isRegistered = false;

      // If we had a token, try to logout from server
      if (currentToken != null && currentToken.isNotEmpty) {
        final serverLogoutResult = await _authRemoteService.logout(
          currentToken,
        );

        // Note: We don't fail the whole logout if server logout fails
        // The user is considered logged out locally regardless
        if (serverLogoutResult.isError()) {
          // Log the error but don't return it
          log("Warning: Server logout failed, but user is logged out locally");
        }
      }

      return Result.success(null);
    } catch (e) {
      // Even if there's an error, ensure local session is cleared
      _isRegistered = false;

      return Result.error(Exception("Erro durante logout: $e"));
    }
  }

  // =============================================================================
  // UTILITY METHODS (for internal use and debugging)
  // =============================================================================

  /// Check if token repository has been initialized
  bool get isTokenRepositoryInitialized => _tokenRepository.isInitialized;

  /// Force reload cache from storage and sync with server
  Future<void> reloadCache() async {
    await _tokenRepository.reload();
    await _loadRegistrationStatus();
  }
}
