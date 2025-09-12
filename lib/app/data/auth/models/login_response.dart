class LoginResponse {
  /// Session token provided by the backend (Laravel Sanctum token)
  final String? sessionToken;

  /// Indicates if additional registration steps are needed
  final bool isRegistered;

  const LoginResponse({required this.sessionToken, required this.isRegistered});
}
