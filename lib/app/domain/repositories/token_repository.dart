import 'package:multiple_result/multiple_result.dart';

abstract class TokenRepository {
  Future<void> reload();
  Future<void> clearToken();
  Future<Result<String, Exception>> getToken();
  Future<void> setToken(String token);
}
