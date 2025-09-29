import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:minha_saude_frontend/app/domain/models/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

export 'auth_repository_local.dart';

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
  Future<Result<void, Exception>> register(UserRegisterModel registerModel);

  /// Sign out the current user, both through server and clearing local data
  Future<void> logout();

  // [GOOGLE INTEGRATION]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String, Exception>> getGoogleServerToken();

  // [STORED TOKENS]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String?, Exception>> getAuthToken();

  /// Sets the current auth token in session storage
  Future<Result<void, Exception>> setAuthToken(String? value);

  /// Checks if user has auth token
  Future<bool> hasAuthToken();

  /// Gets the locally stored register token
  String? getRegisterToken();

  /// Sets the locally stored register token
  bool setRegisterToken(String? value);

  /// Checks if the user has a register token
  bool hasRegisterToken();
}
