import 'dart:developer';

import 'package:minha_saude_frontend/app/data/auth/services/auth_cache_service.dart';
import 'package:minha_saude_frontend/app/data/auth/services/auth_storage_service.dart';
import 'package:multiple_result/multiple_result.dart';

/// Repository responsible for managing authentication tokens and registration status
/// Uses AuthCacheService for in-memory caching and AuthStorageService for persistence
class AuthTokenRepository {
  final AuthCacheService _cacheService;
  final AuthStorageService _storageService;

  static Future<AuthTokenRepository> create(
    AuthCacheService cacheService,
    AuthStorageService storageService,
  ) async {
    final repository = AuthTokenRepository._(cacheService, storageService);
    await repository._initializeCache();
    return repository;
  }

  AuthTokenRepository._(this._cacheService, this._storageService);

  bool _cacheInitialized = false;

  /// Initialize the cache from local storage
  Future<void> _initializeCache() async {
    try {
      // Load token from secure storage
      final tokenResult = await _storageService.getSessionToken();
      if (tokenResult.isSuccess()) {
        final token = tokenResult.tryGetSuccess();
        if (token != null) {
          _cacheService.setToken(token);
        }
      }

      _cacheInitialized = true;
    } catch (e) {
      log("Error initializing token cache: $e");
      _cacheInitialized = true; // Mark as initialized even on error
    }
  }

  // =============================================================================
  // TOKEN MANAGEMENT
  // =============================================================================

  /// Get the current authentication token
  String? get authToken {
    return _cacheService.token;
  }

  /// Check if user has a valid token
  bool get hasToken {
    if (!_cacheInitialized) return false;
    return _cacheService.hasToken;
  }

  /// Check if user is logged in (has a valid token)
  bool get isLoggedIn {
    if (!_cacheInitialized) return false;
    return _cacheService.isLoggedIn;
  }

  /// Set a new authentication token
  Future<Result<void, Exception>> setToken(String token) async {
    try {
      _cacheService.setToken(token);
      final result = await _storageService.setSessionToken(token);

      if (result.isError()) {
        // Rollback cache if storage fails
        _cacheService.clearCache();
        return Result.error(
          Exception("Failed to persist token: ${result.tryGetError()}"),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error setting token: $e"));
    }
  }

  /// Remove the current authentication token
  Future<Result<void, Exception>> removeToken() async {
    try {
      _cacheService.clearCache();
      final result = await _storageService.removeSessionToken();

      if (result.isError()) {
        return Result.error(
          Exception(
            "Failed to remove token from storage: ${result.tryGetError()}",
          ),
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error removing token: $e"));
    }
  }

  // =============================================================================
  // REGISTRATION STATUS MANAGEMENT
  // =============================================================================

  /// Check if user is registered (completed profile)
  bool get isRegistered {
    if (!_cacheInitialized) return false;
    return _cacheService.isRegistered;
  }

  /// Set user registration status
  void setRegistered(bool isRegistered) {
    _cacheService.setRegistered(isRegistered);
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if cache has been initialized
  bool get isCacheInitialized => _cacheInitialized;

  /// Force reload cache from storage
  Future<void> reloadCache() async {
    await _initializeCache();
  }

  /// Clear all authentication data (token and registration status)
  Future<Result<void, Exception>> clearAll() async {
    return await removeToken();
  }
}
