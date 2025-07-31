import 'package:injectable/injectable.dart';

@singleton
class GoogleAuthConfig {
  final String clientId;
  final String serverClientId;

  GoogleAuthConfig()
    : clientId = const String.fromEnvironment('CLIENT_ID'),
      serverClientId = const String.fromEnvironment('SERVER_CLIENT_ID') {
    if (clientId.isEmpty) {
      throw GoogleAuthException(
        "Missing required environment variable 'clientId'. Use 'flutter run --dart-define-from-file .env'",
      );
    }

    if (serverClientId.isEmpty) {
      throw GoogleAuthException(
        "Missing required environment variable 'serverClientId'. Use 'flutter run --dart-define-from-file .env'",
      );
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;

  const GoogleAuthException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}
