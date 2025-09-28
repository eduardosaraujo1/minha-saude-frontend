class GoogleAuthConfig {
  final String _clientId;
  final String _serverClientId;
  final List<String> _scopes;

  const GoogleAuthConfig({
    required String clientId,
    required String serverClientId,
    required List<String> scopes,
  }) : _clientId = clientId,
       _serverClientId = serverClientId,
       _scopes = scopes;

  factory GoogleAuthConfig.fromEnv({required List<String> scopes}) {
    final clientId = String.fromEnvironment('CLIENT_ID');
    final serverClientId = String.fromEnvironment('SERVER_CLIENT_ID');

    if (clientId.isEmpty) {
      throw ArgumentError('CLIENT_ID environment variable is not set.');
    }
    if (serverClientId.isEmpty) {
      throw ArgumentError('SERVER_CLIENT_ID environment variable is not set.');
    }

    return GoogleAuthConfig(
      clientId: clientId,
      serverClientId: serverClientId,
      scopes: scopes,
    );
  }

  String get clientId => _clientId;
  String get serverClientId => _serverClientId;
  List<String> get scopes => _scopes;
}
