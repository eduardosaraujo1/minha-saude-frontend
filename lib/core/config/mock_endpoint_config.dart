class MockEndpointConfig {
  final GoogleSignInMode googleSignInMode;
  final ServerAuthMode serverAuthMode;
  final DocumentCreateMode documentCreateMode;

  const MockEndpointConfig({
    required this.googleSignInMode,
    required this.serverAuthMode,
    required this.documentCreateMode,
  });
}

enum DocumentCreateMode { scan, asset }

enum GoogleSignInMode { real, mockError, mockSuccess }

enum ServerAuthMode {
  mockNewUser,
  mockExistingUser,
  mockLoginError,
  mockRegisterError,
}
