import 'package:minha_saude_frontend/app/data/services/api_client.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  const AuthRepositoryImpl(this.apiClient);

  @override
  Future<Result<String, Exception>> googleLogin(String serverCode) async {
    try {
      final loginResponse = await _sendLoginRequest(serverCode);
      if (loginResponse.isError()) {
        return Result.error(loginResponse.tryGetError()!);
      }
      final response = loginResponse.tryGetSuccess()!;
      return Result.success(response);
    } catch (e) {
      return Result.error(Exception("Erro inesperado durante o login: $e"));
    }
  }

  Future<LoginResu _sendLoginRequest(String serverCode) async {}

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
