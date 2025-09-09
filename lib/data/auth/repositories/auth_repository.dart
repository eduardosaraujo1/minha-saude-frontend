import 'package:minha_saude_frontend/data/auth/DTO/auth_response.dart';
import 'package:minha_saude_frontend/data/auth/DTO/register_response.dart';
import 'package:minha_saude_frontend/data/auth/sources/auth_remote_data_source.dart';
import 'package:minha_saude_frontend/data/auth/sources/google_sign_in_data_source.dart';
import 'package:minha_saude_frontend/data/auth/models/user.dart';
import 'package:multiple_result/multiple_result.dart';

// TODO: colocar mais responsabilidades no repositório, como comunicação com Gateway etc.
// Somente se ficar muito bagunçado o código que é recomendado criar o AuthRemoteDataSource
class AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final GoogleSignInDataSource _googleSignInDataSource;
  AuthRepository(this._authRemoteDataSource, this._googleSignInDataSource);
  // Uses GoogleSignInDataSource and AuthRemoteDataSource
  // function loginWithGoogle
  // function registerWithGoogle
  // function logout
  Future<Result<LoginResponse, Exception>> loginWithGoogle() async {
    // Implement login with Google logic here
    final googleSignInResult = await _googleSignInDataSource
        .generateServerAuthCode();

    if (googleSignInResult.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao autenticar com o Google"),
      );
    }

    final sanctumToken = await _authRemoteDataSource.loginWithGoogle(
      googleSignInResult.tryGetSuccess()!,
    );

    if (sanctumToken.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao autenticar com o backend"),
      );
    }

    return Result.success(sanctumToken.tryGetSuccess()!);
  }

  Future<Result<RegisterResponse, Exception>> registerWithGoogle() async {
    final registerResult = await _authRemoteDataSource.registerWithGoogle(
      User(
        id: "1",
        cpf: "123.456.789-00",
        email: "john.doe@example.com",
        name: "John Doe",
        telefone: '+55 11 98314-6365',
        birthDate: '1990-01-01',
      ),
    );

    if (registerResult.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao registrar com o backend"),
      );
    }

    return Result.success(registerResult.tryGetSuccess()!);
  }
}
