import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_storage_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_remote_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/google_sign_in_service.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepository implements IAuthRepository {
  final AuthRemoteService _authRemoteService;
  final AuthStorageService _authStorageService;
  final GoogleSignInService _googleSignInService;

  static Future<AuthRepository> create(
    AuthStorageService authStorageService,
    AuthRemoteService authRemoteService,
    GoogleSignInService googleSignInService,
  ) async {
    final repository = AuthRepository._(
      authRemoteService,
      authStorageService,
      googleSignInService,
    );
    await repository._initializeCache();

    return repository;
  }

  // Cache for synchronous access
  String? _cachedToken;
  bool? _cachedIsRegistered;
  bool _cacheInitialized = false;

  AuthRepository._(
    this._authRemoteService,
    this._authStorageService,
    this._googleSignInService,
  );

  /// Initialize the cache from local storage and remote status
  Future<void> _initializeCache() async {
    try {
      // Load token from secure storage
      final tokenResult = await _authStorageService.getSessionToken();
      if (tokenResult.isSuccess()) {
        _cachedToken = tokenResult.tryGetSuccess();
      }

      // If we have a token, check registration status with server
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        final statusResult = await _authRemoteService.getAuthStatus(
          _cachedToken!,
        );
        if (statusResult.isSuccess()) {
          final status = statusResult.tryGetSuccess();
          _cachedIsRegistered = status?.isRegistered;
        }
      } else {
        _cachedIsRegistered = false;
      }

      _cacheInitialized = true;
    } catch (e) {
      log("Error initializing cache: $e");
      _cacheInitialized = true; // Mark as initialized even on error
    }
  }

  /// Update cache and storage with new token
  Future<void> _updateTokenAndCache(String? token, {bool? isRegistered}) async {
    _cachedToken = token;
    _cachedIsRegistered = isRegistered;

    if (token != null) {
      await _authStorageService.setSessionToken(token);
    } else {
      await _authStorageService.removeSessionToken();
    }
  }

  /// Clear cache and storage
  Future<void> _clearCacheAndStorage() async {
    _cachedToken = null;
    _cachedIsRegistered = null;
    await _authStorageService.removeSessionToken();
  }

  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  @override
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

      // Update cache and storage with token and registration status
      await _updateTokenAndCache(
        response.sessionToken,
        isRegistered: true, // User is registered if login was successful
      );

      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o login: $e"));
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> register(User userData) async {
    try {
      // Get Google auth code first
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

      // Attempt registration with backend
      final registerResult = await _authRemoteService.register(userData);

      if (registerResult.isError()) {
        return Result.error(
          Exception(
            "Ocorreu um erro ao registrar. Verifique sua conexão com a internet",
          ),
        );
      }

      final response = registerResult.tryGetSuccess()!;

      // Update registration status in cache (no token yet)
      _cachedIsRegistered = true;

      return Result.success(response);
    } catch (e) {
      log(e.toString());
      return Result.error(Exception("Ocorreu um erro desconhecido."));
    }
  }

  // =============================================================================
  // READ OPERATIONS (Token retrieval and status checks)
  // =============================================================================

  @override
  String? get authToken {
    return _cachedToken;
  }

  @override
  bool get isRegistered {
    // If cache not initialized, return false (conservative approach)
    if (!_cacheInitialized) return false;

    return _cachedIsRegistered ?? false;
  }

  bool get isLoggedIn {
    // If cache not initialized, return false (conservative approach)
    if (!_cacheInitialized) return false;

    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  @override
  Future<Result<void, Exception>> signOut() async {
    try {
      final currentToken = _cachedToken;

      // Clear local session first (even if server logout fails)
      await _clearCacheAndStorage();

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
        await _clearCacheAndStorage();
      } catch (clearError) {
        log("Error clearing cache during signOut: $clearError");
      }

      return Result.error(Exception("Erro durante logout: $e"));
    }
  }

  // =============================================================================
  // UTILITY METHODS (for internal use and debugging)
  // =============================================================================

  /// Check if cache has been initialized
  bool get isCacheInitialized => _cacheInitialized;

  /// Force reload cache from storage and server (useful for debugging)
  Future<void> reloadCache() async {
    await _initializeCache();
  }
}
