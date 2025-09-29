import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

export 'auth_repository_local.dart';

abstract class AuthRepository {
  // [AUTHENTICATION]

  /// Login with Google exchanging server code for auth token and storing in SecureStorage
  /// If the login fails because the user was not registered, the register token is remembered instead
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
  Future<Result<void, Exception>> register(UserRegisterModel registerModel);

  /// Register a new user through token from login attempt
  Result<String?, Exception> getRegisterToken();

  /// Check if the user has a register token
  bool hasRegisterToken();

  /// Sign out the current user, both through server and clearing local data
  Future<void> logout();

  // [GOOGLE INTEGRATION]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String, Exception>> getGoogleServerToken();

  // [STORED TOKEN]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String?, Exception>> getAuthToken();

  Future<bool> hasToken();
}
