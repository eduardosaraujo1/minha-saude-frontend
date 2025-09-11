import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_local_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService _authRemoteService;
  final AuthLocalService _authLocalService;
  final GoogleSignInService _googleSignInService;

  static AuthRepositoryImpl create(
    AuthLocalService authLocalService,
    AuthRemoteService authRemoteService,
    GoogleSignInService googleSignInService,
  ) {
    return AuthRepositoryImpl._(
      authRemoteService,
      authLocalService,
      googleSignInService,
    ).._initializeTokenCache();
  }

  // Cached token for synchronous access
  String? _cachedToken;
  bool _tokenLoaded = false;

  AuthRepositoryImpl._(
    this._authRemoteService,
    this._authLocalService,
    this._googleSignInService,
  );

  /// Initialize the token cache from local storage
  Future<void> _initializeTokenCache() async {
    final tokenResult = await _authLocalService.getSessionToken();
    if (tokenResult.isSuccess()) {
      _cachedToken = tokenResult.tryGetSuccess();
    }
    _tokenLoaded = true;
  }

  /// Update both cache and local storage with new token
  Future<void> _updateTokenCache(String? token) async {
    _cachedToken = token;
    if (token != null) {
      await _authLocalService.setSessionToken(token);
    }
  }

  /// Clear both cache and local storage
  Future<void> _clearTokenCache() async {
    _cachedToken = null;
    await _authLocalService.removeSessionToken();
  }

  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  @override
  Future<Result<LoginResponse, Exception>> loginWithGoogle() async {
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

      // If we have a session token, cache it
      if (response.sessionToken != null) {
        await _updateTokenCache(response.sessionToken);
      }

      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o login: $e"));
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> registerWithGoogle(
    User userData,
  ) async {
    try {
      // Attempt registration with backend
      final registerResult = await _authRemoteService.register(userData);

      if (registerResult.isError()) {
        return Result.error(
          Exception("Ocorreu um erro ao registrar com o backend"),
        );
      }

      final response = registerResult.tryGetSuccess()!;

      // Note: Registration doesn't automatically log the user in
      // The login flow should be called separately to obtain session token

      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o registro: $e"));
    }
  }

  // =============================================================================
  // READ OPERATIONS (Token retrieval and status checks)
  // =============================================================================

  @override
  Future<Result<String?, Exception>> getLocalToken() async {
    try {
      final result = await _authLocalService.getSessionToken();

      // Update cache with the latest value from storage
      if (result.isSuccess()) {
        _cachedToken = result.tryGetSuccess();
        _tokenLoaded = true;
      }

      return result;
    } catch (e) {
      return Result.error(Exception("Erro ao obter token local: $e"));
    }
  }

  @override
  String? getCachedToken() {
    return _cachedToken;
  }

  @override
  bool isLoggedIn() {
    // Return false if cache hasn't been loaded yet or token is null/empty
    if (!_tokenLoaded) return false;
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  @override
  Future<bool> isLoggedInAsync() async {
    try {
      return await _authLocalService.hasValidSession();
    } catch (e) {
      log("Error checking login status: $e");
      return false;
    }
  }

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  @override
  Future<Result<void, Exception>> logout() async {
    try {
      final currentToken = _cachedToken;

      // Clear local session first (even if server logout fails)
      await _clearTokenCache();

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
      try {
        await _clearTokenCache();
      } catch (clearError) {
        log("Error clearing cache during logout: $clearError");
      }

      return Result.error(Exception("Erro durante logout: $e"));
    }
  }

  @override
  Future<Result<void, Exception>> clearLocalSession() async {
    try {
      await _clearTokenCache();
      return Result.success(null);
    } catch (e) {
      return Result.error(
        Exception("Não foi possível limpar sessão local: $e"),
      );
    }
  }

  // =============================================================================
  // UTILITY METHODS (for internal use and debugging)
  // =============================================================================

  /// Check if token cache has been initialized
  bool get isTokenCacheLoaded => _tokenLoaded;

  /// Force reload token cache from storage (useful for debugging)
  Future<void> reloadTokenCache() async {
    await _initializeTokenCache();
  }
}
