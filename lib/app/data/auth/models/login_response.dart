class LoginResponse {
  /// Indicates if user has completed registration
  final bool isRegistered;

  /// Session token for authenticated users (only when isRegistered = true)
  final String? sessionToken;

  /// Register token for users who need to complete registration (only when isRegistered = false)
  final String? registerToken;

  /// Token expiration time
  final DateTime? expiresAt;

  const LoginResponse({
    required this.isRegistered,
    this.sessionToken,
    this.registerToken,
    this.expiresAt,
  });
}
