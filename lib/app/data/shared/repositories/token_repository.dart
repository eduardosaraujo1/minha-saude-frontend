import 'dart:developer';

import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

/// Shared repository responsible for managing authentication tokens only
/// This provides a clean separation between token storage and auth-specific logic
class TokenRepository {
  static const String keyUserId = 'session_token';

  final SecureStorage _storage;

  TokenRepository(this._storage);

  String? _cachedToken;
  bool _cacheLoaded = false;

  /// Get the current authentication token (lazy-loaded)
  Future<String?> getToken() async {
    if (!_cacheLoaded) {
      await _refreshTokenCache();
    }

    return _cachedToken;
  }

  /// Get the cached token without loading from storage (may be null if not loaded yet)
  String? get tokenCached => _cachedToken;

  /// Check if user has a valid token (lazy-loaded)
  Future<bool> hasToken() async {
    if (!_cacheLoaded) {
      await _refreshTokenCache();
    }
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  /// Lazy load token from storage if not already cached
  Future<void> _refreshTokenCache() async {
    _cacheLoaded = false;

    try {
      final token = await _storage.read(keyUserId);
      _cachedToken = token;
      _cacheLoaded = true;
    } catch (e) {
      log("Error loading token from storage: $e");
      _cachedToken = null;
      _cacheLoaded = true; // Mark as loaded even on error to avoid retry loops
    }
  }

  /// Set a new authentication token
  Future<Result<void, Exception>> setToken(String token) async {
    try {
      await _storage.write(keyUserId, token);
      _cachedToken = token;
      _cacheLoaded = true; // Mark cache as loaded with new value
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error setting token: $e"));
    }
  }

  /// Remove the current authentication token
  Future<Result<void, Exception>> removeToken() async {
    try {
      await _storage.delete(keyUserId);
      _cachedToken = null;
      _cacheLoaded = true; // Mark cache as loaded with null value
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error removing token: $e"));
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Force reload token from storage
  Future<void> reload() async {
    await _refreshTokenCache(); // Reload from storage
  }
}
