import 'dart:collection';

class GoogleAuthConfig {
  static const String _clientId = String.fromEnvironment(
    'CLIENT_ID',
    defaultValue: '',
  );
  static const String _serverClientId = String.fromEnvironment(
    'SERVER_CLIENT_ID',
    defaultValue: '',
  );
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    'openid',
  ];

  GoogleAuthConfig() {
    if (_clientId.isEmpty) {
      throw ArgumentError('CLIENT_ID environment variable is not set.');
    }
    if (_serverClientId.isEmpty) {
      throw ArgumentError('SERVER_CLIENT_ID environment variable is not set.');
    }
    if (_scopes.isEmpty) {
      throw ArgumentError('SCOPES value is not set.');
    }
  }

  String get clientId => _clientId;
  String get serverClientId => _serverClientId;
  List<String> get scopes => UnmodifiableListView(_scopes);
}
