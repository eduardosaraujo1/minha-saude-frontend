class ProjectSettings {
  ProjectSettings({
    /// The base URL the API uses
    required String apiBaseUrl,

    /// Use fake ApiClient for server comunication
    required bool mockApiClient,

    /// Use fake GoogleSignIn client
    required bool mockGoogle,

    /// Use fake DocumentScanner client that returns a default PDF
    required bool mockScanner,

    /// Mock the device storage used for token storage
    required bool mockSecureStorage,
  }) : _apiBaseUrl = apiBaseUrl,
       _mockApiClient = mockApiClient,
       _mockGoogle = mockGoogle,
       _mockScanner = mockScanner,
       _mockSecureStorage = mockSecureStorage;

  final String _apiBaseUrl;
  final bool _mockApiClient;
  final bool _mockGoogle;
  final bool _mockScanner;
  final bool _mockSecureStorage;

  String get apiBaseUrl => _apiBaseUrl;
  bool get mockApiClient => _mockApiClient;
  bool get mockGoogle => _mockGoogle;
  bool get mockScanner => _mockScanner;
  bool get mockSecureStorage => _mockSecureStorage;
}
