class MockEndpointConfig {
  final GoogleSignInMode googleSignInMode;
  final ServerAuthMode serverAuthMode;

  const MockEndpointConfig({
    required this.googleSignInMode,
    required this.serverAuthMode,
  });
}

enum GoogleSignInMode { real, mockError, mockSuccess }

enum ServerAuthMode {
  mockNewUser,
  mockExistingUser,
  mockLoginError,
  mockRegisterError,
}
