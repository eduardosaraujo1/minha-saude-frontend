class GoogleAuthConfig {
  late String clientId;
  late String serverClientId;

  GoogleAuthConfig() {
    readEnv();
  }

  void readEnv() {
    const String clientId = String.fromEnvironment('CLIENT_ID');
    const String serverClientId = String.fromEnvironment('SERVER_CLIENT_ID');

    if (clientId.isEmpty) {
      throw GoogleAuthException(
        "Missing required environment variable 'clientId'",
      );
    }

    if (serverClientId.isEmpty) {
      throw GoogleAuthException(
        "Missing required environment variable 'serverClientId'",
      );
    }

    this.clientId = clientId;
    this.serverClientId = serverClientId;
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}
