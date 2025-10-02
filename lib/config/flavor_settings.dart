/// Configuration settings for different app flavors (development, production).
///
/// This class manages environment-specific configuration values using a singleton pattern.
/// It automatically loads configuration from environment variables by default, with the
/// option to override values programmatically.
///
/// ## Environment Variables
///
/// The following environment variables are used (property names converted to SCREAMING_CASE):
/// - `API_URL` → `apiBaseUrl` (default: 'https://localhost:8000')
/// - `GOOGLE_CLIENT_ID` → `googleClientId` (required, no default)
/// - `GOOGLE_SERVER_CLIENT_ID` → `googleServerClientId` (required, no default)
///
/// ## Usage
///
/// ```dart
/// // Setup with environment variables (recommended)
/// FlavorSettings.setup(flavor: Flavor.development);
///
/// // Setup with explicit values (for testing or special cases)
/// FlavorSettings.setup(
///   flavor: Flavor.production,
///   apiBaseUrl: 'https://api.example.com',
///   googleClientId: 'your-client-id',
///   googleServerClientId: 'your-server-client-id',
/// );
///
/// // Access configuration
/// final settings = FlavorSettings.instance;
/// print(settings.apiBaseUrl);
/// ```
///
/// **Note**: `setup()` must be called exactly once before accessing the instance.
/// Attempting to call it multiple times will throw an exception.
class FlavorSettings {
  FlavorSettings._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.googleClientId,
    required this.googleServerClientId,
  });

  /// The current app flavor (development or production).
  late final Flavor flavor;

  /// Base URL for API endpoints.
  /// Loaded from `API_URL` environment variable, defaults to 'https://localhost:8000'.
  late final String apiBaseUrl;

  /// Google OAuth client ID for authentication.
  /// Loaded from `GOOGLE_CLIENT_ID` environment variable (required).
  late final String googleClientId;

  /// Google OAuth server client ID for backend authentication.
  /// Loaded from `GOOGLE_SERVER_CLIENT_ID` environment variable (required).
  late final String googleServerClientId;

  static FlavorSettings? _instance;

  /// Gets the singleton instance of FlavorSettings.
  ///
  /// Throws an exception if [setup] hasn't been called yet.
  static FlavorSettings get instance => _instance!;

  /// Initializes the FlavorSettings singleton with the specified configuration.
  ///
  /// This method must be called exactly once before accessing [instance].
  ///
  /// ## Parameters
  ///
  /// - [flavor]: The app flavor (development or production) - required
  /// - [apiBaseUrl]: Override for API base URL (optional, uses `API_URL` env var by default)
  /// - [googleClientId]: Override for Google client ID (optional, uses `GOOGLE_CLIENT_ID` env var by default)
  /// - [googleServerClientId]: Override for Google server client ID (optional, uses `GOOGLE_SERVER_CLIENT_ID` env var by default)
  ///
  /// ## Environment Variable Fallbacks
  ///
  /// When optional parameters are not provided, the method automatically loads values from
  /// environment variables using the property names converted to SCREAMING_CASE:
  ///
  /// - `apiBaseUrl` → `API_URL` (default: 'https://localhost:8000')
  /// - `googleClientId` → `GOOGLE_CLIENT_ID` (required, will throw if not set)
  /// - `googleServerClientId` → `GOOGLE_SERVER_CLIENT_ID` (required, will throw if not set)
  ///
  /// ## Throws
  ///
  /// - [Exception] if called multiple times
  /// - [ArgumentError] if required environment variables are not set
  static void setup({
    required Flavor flavor,
    String? apiBaseUrl,
    String? googleClientId,
    String? googleServerClientId,
  }) {
    if (_instance != null) {
      throw Exception('Attempted to initialize Settings twice');
    }

    // Load configuration from environment variables with fallbacks
    final resolvedApiBaseUrl =
        apiBaseUrl ??
        const String.fromEnvironment(
          "API_URL",
          defaultValue: 'https://localhost:8000',
        );

    final resolvedGoogleClientId =
        googleClientId ??
        const String.fromEnvironment("GOOGLE_CLIENT_ID", defaultValue: '');

    final resolvedGoogleServerClientId =
        googleServerClientId ??
        const String.fromEnvironment(
          "GOOGLE_SERVER_CLIENT_ID",
          defaultValue: '',
        );

    // Validate required environment variables
    if (resolvedGoogleClientId.isEmpty) {
      throw ArgumentError('GOOGLE_CLIENT_ID environment variable is not set.');
    }

    if (resolvedGoogleServerClientId.isEmpty) {
      throw ArgumentError(
        'GOOGLE_SERVER_CLIENT_ID environment variable is not set.',
      );
    }

    _instance = FlavorSettings._(
      flavor: flavor,
      apiBaseUrl: resolvedApiBaseUrl,
      googleClientId: resolvedGoogleClientId,
      googleServerClientId: resolvedGoogleServerClientId,
    );
  }
}

/// Represents the different deployment environments for the application.
///
/// - [development]: Development environment with debug features enabled
/// - [production]: Production environment optimized for end users
enum Flavor { development, production }
