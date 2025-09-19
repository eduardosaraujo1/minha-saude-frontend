import 'package:multiple_result/multiple_result.dart';

abstract class AuthRepository {
  Future<Result<String, Exception>> googleLogin(String serverCode);
  Future<void> signOut();
}
