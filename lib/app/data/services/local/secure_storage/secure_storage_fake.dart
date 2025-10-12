import 'package:multiple_result/multiple_result.dart';

import 'secure_storage.dart';

class SecureStorageFake implements SecureStorage {
  String? _token;

  /// Read the token from secure storage
  @override
  Future<Result<String?, Exception>> getAuthToken() async {
    return Result.success(_token);
  }

  /// Set the token in secure storage
  @override
  Future<Result<void, Exception>> setAuthToken(String token) async {
    _token = token;

    return Result.success(null);
  }

  @override
  Future<Result<void, Exception>> clearAuthToken() async {
    _token = null;

    return Result.success(null);
  }
}
