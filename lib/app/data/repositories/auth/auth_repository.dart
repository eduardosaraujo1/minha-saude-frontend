import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

export 'auth_repository_impl.dart';

abstract class AuthRepository extends ChangeNotifier {
  // [AUTHENTICATION]
  /// Login with Google exchanging server code for auth token
  Future<Result<LoginResult, Exception>> loginWithGoogle(
    String googleServerCode,
  );

  /// Login with email and code
  Future<Result<LoginResult, Exception>> loginWithEmail(
    String email,
    String code,
  );

  /// Get e-mail code for login
  Future<Result<void, Exception>> requestEmailCode(String email);

  /// Register a new user through token from login attempt
  ///
  /// Returns [String] which is the auth session token if registration succeeds
  Future<Result<String, Exception>> register(UserRegisterModel registerModel);

  /// Sign out the current user, both through server and clearing local data
  /// Clears the CacheDatabase as well as the auth token stored in SecureStorage
  Future<void> logout();

  // [GOOGLE INTEGRATION]
  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String, Exception>> getGoogleServerToken();
}
