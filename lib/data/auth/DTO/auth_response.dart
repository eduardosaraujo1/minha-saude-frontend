class LoginResponse {
  // Session Token (nullable string)
  // needsRegistration (boolean)
  final String? sessionToken;
  final bool needsRegistration;

  const LoginResponse(this.sessionToken, this.needsRegistration);
}
