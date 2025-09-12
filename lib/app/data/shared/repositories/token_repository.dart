import 'dart:developer';

import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

/// Shared repository responsible for managing authentication tokens only
/// This provides a clean separation between token storage and auth-specific logic
class TokenRepository {
  final SecureStorage _storage;

  TokenRepository._(this._storage);

  static const String _tokenKey = 'session_token';

  String? _cachedToken;
  bool _isInitialized = false;

  static Future<TokenRepository> create(SecureStorage storage) async {
    final repository = TokenRepository._(storage);
    await repository._loadToken();
    return repository;
  }

  /// Initialize the repository by loading token from storage
  Future<void> _loadToken() async {
    try {
      final token = await _storage.read(_tokenKey);
      _cachedToken = token;
      _isInitialized = true;
    } catch (e) {
      log("Error initializing token repository: $e");
      _isInitialized = true; // Mark as initialized even on error
    }
  }

  // =============================================================================
  // TOKEN MANAGEMENT
  // =============================================================================

  /// Get the current authentication token
  String? get token {
    return _cachedToken;
  }

  /// Check if user has a valid token
  bool get hasToken {
    if (!_isInitialized) return false;
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }

  /// Set a new authentication token
  Future<Result<void, Exception>> setToken(String token) async {
    try {
      await _storage.write(_tokenKey, token);
      _cachedToken = token;
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error setting token: $e"));
    }
  }

  /// Remove the current authentication token
  Future<Result<void, Exception>> removeToken() async {
    try {
      await _storage.delete(_tokenKey);
      _cachedToken = null;
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error removing token: $e"));
    }
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if repository has been initialized
  bool get isInitialized => _isInitialized;

  /// Force reload token from storage
  Future<void> reload() async {
    await _loadToken();
  }
}
