class RegisterResponse {
  final RegisterStatus status;

  /// Session token for successful registration
  final String? sessionToken;

  /// Token expiration time
  final DateTime? expiresAt;

  const RegisterResponse(this.status, {this.sessionToken, this.expiresAt});
}

enum RegisterStatus { success, failure }
