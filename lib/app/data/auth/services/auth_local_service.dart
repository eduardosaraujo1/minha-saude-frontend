import 'package:minha_saude_frontend/app/data/shared/services/secure_storage.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthLocalService {
  final SecureStorage _storage;

  AuthLocalService(this._storage);

  static const String _tokenKey = 'session_token';

  /// Get current session token
  Future<Result<String?, Exception>> getSessionToken() async {
    try {
      final token = await _storage.read(_tokenKey);
      return Result.success(token);
    } catch (e) {
      return Result.error(Exception('Failed to get session token: $e'));
    }
  }

  /// Set session token to local storage
  Future<Result<void, Exception>> setSessionToken(String token) async {
    try {
      await _storage.write(_tokenKey, token);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception('Failed to cache session token: $e'));
    }
  }

  /// Remove session token from local storage
  Future<Result<void, Exception>> removeSessionToken() async {
    try {
      await _storage.delete(_tokenKey);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception('Failed to remove session token: $e'));
    }
  }

  /// Check if user has a valid session token
  Future<bool> hasValidSession() async {
    final tokenResult = await getSessionToken();
    return tokenResult.isSuccess() && tokenResult.tryGetSuccess() != null;
  }
}
