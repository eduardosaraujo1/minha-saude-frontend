import 'package:minha_saude_frontend/app/data/services/google/google_service.dart';
import 'package:multiple_result/multiple_result.dart';

class GoogleServiceFake implements GoogleService {
  @override
  Future<Result<String?, Exception>> generateServerAuthCode() async {
    return Future.delayed(
      Duration(seconds: 2),
      () => Result.success("fake_server_auth_code"),
    );
  }
}
