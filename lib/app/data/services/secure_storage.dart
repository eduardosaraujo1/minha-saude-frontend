// Wrapper for FlutterSecureStorage
// Provides methods to read, write, and delete key-value pairs securely.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

class SecureStorage {
  static const String tokenKey = 'session_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Read a value directly from secure storage
  Future<String?> _read(String key) async {
    return await _storage.read(key: key);
  }

  /// Write a value directly to secure storage
  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete a value directly from secure storage
  Future<void> _delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Read the token from secure storage
  Future<Result<String?, Exception>> getAuthToken() async {
    try {
      final token = await _read(tokenKey);
      return Result.success(token);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// Set the token in secure storage
  Future<Result<void, Exception>> setAuthToken(String? token) async {
    try {
      if (token == null) {
        await _delete(tokenKey);
      } else {
        await _write(tokenKey, token);
      }
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
