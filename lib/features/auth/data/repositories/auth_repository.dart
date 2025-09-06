import 'package:minha_saude_frontend/features/auth/data/models/auth_response.dart';
import 'package:minha_saude_frontend/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:minha_saude_frontend/features/auth/data/sources/google_sign_in_data_source.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final GoogleSignInDataSource _googleSignInDataSource;
  AuthRepository(this._authRemoteDataSource, this._googleSignInDataSource);
  // Uses GoogleSignInDataSource and AuthRemoteDataSource
  // function loginWithGoogle
  // function registerWithGoogle
  // function logout
  Future<Result<AuthResponse, Exception>> loginWithGoogle() async {
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
}
