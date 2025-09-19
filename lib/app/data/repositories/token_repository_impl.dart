import 'dart:developer';

import 'package:minha_saude_frontend/app/data/services/api_client.dart';
import 'package:minha_saude_frontend/app/data/services/secure_storage.dart';
import 'package:minha_saude_frontend/app/domain/repositories/token_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class TokenRepositoryImpl implements TokenRepository {
  static const String keyUserId = 'session_token';

  final SecureStorage secureStorage;
  final ApiClient apiClient;

  TokenRepositoryImpl(this.secureStorage, this.apiClient);

  String? _cachedToken;
  bool _cacheLoaded = false;

  @override
  Future<void> reload() async {
    _cacheLoaded = false;

    try {
      final token = await secureStorage.read(keyUserId);
      _cachedToken = token;
    } catch (e) {
      log("Error loading token from storage: $e");
      _cachedToken = null;
    } finally {
      _cacheLoaded = true; // Mark as loaded even on error to avoid retry loops
    }
  }

  @override
  Future<Result<void, Exception>> clearToken() async {
    try {
      await secureStorage.delete(keyUserId);
      _cachedToken = null;
      _cacheLoaded = true; // Mark cache as loaded with null value
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Error removing token: $e"));
    }
  }

  @override
  Future<String> getToken() async {
    if (!_cacheLoaded) {
      await reload();
    }

    return _cachedToken!;
  }

  @override
  Future<void> setToken(String token) {
    // TODO: implement setToken
    throw UnimplementedError();
  }
}
