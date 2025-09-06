class AuthResponse {
  // Session Token (nullable string)
  // needsRegistration (boolean)
  final String? sessionToken;
  final bool needsRegistration;

  const AuthResponse(this.sessionToken, this.needsRegistration);
}
