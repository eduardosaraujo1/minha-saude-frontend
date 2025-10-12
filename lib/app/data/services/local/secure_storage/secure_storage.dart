import 'package:multiple_result/multiple_result.dart';

export 'secure_storage_impl.dart';
export 'secure_storage_fake.dart';

abstract class SecureStorage {
  /// Read the token from secure storage
  Future<Result<String?, Exception>> getAuthToken();

  /// Set the token in secure storage
  Future<Result<void, Exception>> setAuthToken(String token);

  /// Set the token in secure storage
  Future<Result<void, Exception>> clearAuthToken();
}
