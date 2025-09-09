import 'package:minha_saude_frontend/app/data/auth/DTO/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/DTO/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/DTO/user_dto.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/auth_local_data_source.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/auth_remote_data_source.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/google_sign_in_data_source.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final GoogleSignInDataSource _googleSignInDataSource;

  AuthRepository(
    this._authRemoteDataSource,
    this._authLocalDataSource,
    this._googleSignInDataSource,
  );

  /// Login with Google and cache session token
  Future<Result<LoginResponse, Exception>> loginWithGoogle() async {
    // Get Google auth code
    final googleSignInResult = await _googleSignInDataSource
        .generateServerAuthCode();

    if (googleSignInResult.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao autenticar com o Google"),
      );
    }

    // Exchange with backend for session token
    final loginResponse = await _authRemoteDataSource.loginWithGoogle(
      googleSignInResult.tryGetSuccess()!,
    );

    if (loginResponse.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao autenticar com o backend"),
      );
    }

    final response = loginResponse.tryGetSuccess()!;

    // If we have a session token, cache it
    if (response.sessionToken != null) {
      await _authLocalDataSource.setSessionToken(response.sessionToken!);
    }

    return Result.success(response);
  }

  /// Register user with provided data
  Future<Result<RegisterResponse, Exception>> registerWithGoogle(
    UserDto userData,
  ) async {
    // Attempt registration with backend
    final registerResult = await _authRemoteDataSource.register(userData);

    if (registerResult.isError()) {
      return Result.error(
        Exception("Ocorreu um erro ao registrar com o backend"),
      );
    }

    final response = registerResult.tryGetSuccess()!;

    // If registration was successful, the login flow should be called separately
    // to obtain and cache the session token. Registration doesn't necessarily
    // mean the user is automatically logged in.

    return Result.success(response);
  }

  /// Get current session token
  Future<Result<String?, Exception>> getCurrentToken() async {
    return await _authLocalDataSource.getSessionToken();
  }

  /// Check if user is logged in (has valid session)
  Future<bool> isLoggedIn() async {
    return await _authLocalDataSource.hasValidSession();
  }

  /// Logout user (clear session token and notify server)
  Future<Result<void, Exception>> logout() async {
    // Get current token for server logout
    final tokenResult = await _authLocalDataSource.getSessionToken();

    // Clear local session first (even if server logout fails)
    final clearResult = await _authLocalDataSource.removeSessionToken();
    if (clearResult.isError()) {
      return Result.error(Exception("Erro ao limpar dados locais"));
    }

    // If we had a token, try to logout from server
    if (tokenResult.isSuccess() && tokenResult.tryGetSuccess() != null) {
      final serverLogoutResult = await _authRemoteDataSource.logout(
        tokenResult.tryGetSuccess()!,
      );

      // Note: We don't fail the whole logout if server logout fails
      // The user is considered logged out locally regardless
      if (serverLogoutResult.isError()) {
        // Log the error but don't return it
        print("Warning: Server logout failed, but user is logged out locally");
      }
    }

    return Result.success(null);
  }

  /// Refresh the current session token
  /// TODO: Implement token refresh logic when the backend supports it
  // Future<Result<String?, Exception>> refreshToken() async {
  //   // This would typically make a call to /auth/refresh endpoint
  //   // For now, just return the current token
  //   return await _authLocalDataSource.getSessionToken();
  // }
}
