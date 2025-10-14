/// Represents the different deployment environments for the application.
///
/// - [development]: Development environment with debug features enabled
/// - [production]: Production environment optimized for end users
enum AppEnv {
  development,
  production;

  bool get isProd => this == AppEnv.production;
  bool get isDev => this == AppEnv.development;
}

/// Provides static access to environment configuration values.
class Environment {
  // Private constructor to prevent instantiation
  Environment._();

  /// The current application environment
  static final AppEnv appEnv = _parseAppEnv(
    const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
  );

  /// The API base URL
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Google OAuth client ID
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );

  /// Google OAuth server client ID
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// Helper method to parse string to AppEnv
  static AppEnv _parseAppEnv(String value) {
    switch (value.toLowerCase()) {
      case 'production':
        return AppEnv.production;
      case 'development':
      default:
        return AppEnv.development;
    }
  }
}
