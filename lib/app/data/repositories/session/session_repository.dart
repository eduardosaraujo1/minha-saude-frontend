import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

export 'session_repository_impl.dart';

abstract class SessionRepository extends ChangeNotifier {
  /// Clears all session data, including auth token and register token
  Future<void> logout();

  /// Gets the current auth token, reading from SecureStorage if unavailable in memory
  Future<Result<String?, Exception>> getAuthToken();

  /// Sets the current auth token in session storage
  Future<Result<void, Exception>> setAuthToken(String value);

  /// Clear the auth token stored in SecureStorage
  Future<Result<void, Exception>> clearAuthToken();

  /// Checks if user has auth token
  Future<bool> hasAuthToken();

  /// Gets the locally stored register token
  String? getRegisterToken();

  /// Sets the locally stored register token
  void setRegisterToken(String? value);

  /// Remove locally stored register token
  void clearRegisterToken();

  /// Checks if the user has a register token
  bool hasRegisterToken();
}
