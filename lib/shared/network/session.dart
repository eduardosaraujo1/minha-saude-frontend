import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minha_saude_frontend/shared/models/user.dart';

class AuthSession {
  AuthSession(this._storage);
  final FlutterSecureStorage _storage;

  // Cache values to avoid frequent storage reads
  String? _cachedToken;
  User? _cachedUser;
  AuthState _currentState = AuthState.initial;

  // Keys for secure storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Get current authentication state
  AuthState get state => _currentState;

  /// Get cached token (null if not authenticated)
  String? get token => _cachedToken;

  /// Get cached user data (null if not authenticated)
  User? get user => _cachedUser;

  /// Check if user is authenticated
  bool get isAuthenticated =>
      _currentState == AuthState.authenticated && _cachedToken != null;

  /// Initialize session from storage (call this on app startup)
  Future<void> initialize() async {
    _currentState = AuthState.loading;

    try {
      final token = await _storage.read(key: _tokenKey);
      final userData = await _storage.read(key: _userKey);

      if (token != null && userData != null) {
        _cachedToken = token;
        _cachedUser = User.fromJson(jsonDecode(userData));
        _currentState = AuthState.authenticated;
      } else {
        _currentState = AuthState.unauthenticated;
      }
    } catch (e) {
      _currentState = AuthState.unauthenticated;
      await clear(); // Clear corrupted data
    }
  }

  /// Set authentication data (login)
  Future<void> set({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    _currentState = AuthState.loading;

    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user));

      _cachedToken = token;
      _cachedUser = User.fromJson(user);
      _currentState = AuthState.authenticated;
    } catch (e) {
      _currentState = AuthState.unauthenticated;
      rethrow;
    }
  }

  /// Clear authentication data (logout)
  Future<void> clear() async {
    _currentState = AuthState.loading;

    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);

      _cachedToken = null;
      _cachedUser = null;
      _currentState = AuthState.unauthenticated;
    } catch (e) {
      // Even if storage fails, clear cache
      _cachedToken = null;
      _cachedUser = null;
      _currentState = AuthState.unauthenticated;
    }
  }

  /// Get fresh token from storage (bypass cache)
  Future<String?> getFreshToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      _cachedToken = token;
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Get fresh user data from storage (bypass cache)
  Future<User?> getFreshUser() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        final user = User.fromJson(userJson);
        _cachedUser = user;
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

enum AuthState { initial, authenticated, unauthenticated, loading }
