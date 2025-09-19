class MockEndpointConfig {
  final GoogleSignInMode googleSignInMode;
  final ServerAuthMode serverAuthMode;
  final DocumentCreateMode documentCreateMode = DocumentCreateMode.scan;

  const MockEndpointConfig({
    required this.googleSignInMode,
    required this.serverAuthMode,
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
