import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/register_request/register_request.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class AuthRepository {
  // [AUTHENTICATION]

  /// Login with Google exchanging server code for auth token
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String googleServerCode,
  );

  /// Login with email and code
  Future<Result<LoginResponse, Exception>> loginWithEmail(
    String email,
    String code,
  );

  /// Get e-mail code for login
  Future<Result<void, Exception>> requestEmailCode(String email);

  /// Register a new user through token from login attempt
  Future<Result<void, Exception>> register(RegisterRequest registerRequest);

  /// Sign out the current user
  Future<void> logout();

  // [GOOGLE INTEGRATION]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String?, Exception>> getGoogleServerToken();

  // [TOKEN]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String?, Exception>> getAuthToken();
}
