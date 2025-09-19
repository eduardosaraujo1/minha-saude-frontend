import 'package:multiple_result/multiple_result.dart';

abstract class GoogleAuthRepository {
  Future<Result<String, Exception>> getServerAuthCode();
}
