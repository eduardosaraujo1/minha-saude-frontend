import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

import 'secure_storage.dart';

class SecureStorageImpl implements SecureStorage {
  static const String tokenKey = 'session_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Read a value directly from secure storage
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Write a value directly to secure storage
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete a value directly from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Read the token from secure storage
  @override
  Future<Result<String?, Exception>> getAuthToken() async {
    try {
      final token = await read(tokenKey);
      return Result.success(token);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// Set the token in secure storage
  @override
  Future<Result<void, Exception>> setAuthToken(String token) async {
    try {
      await write(tokenKey, token);

      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void, Exception>> clearAuthToken() async {
    try {
      await delete(tokenKey);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
