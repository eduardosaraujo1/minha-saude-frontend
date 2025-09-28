class ProjectSettings {
  ProjectSettings({
    required bool isProduction,
    required String apiBaseUrl,
    required bool useGoogle,
  }) : _isProduction = isProduction,
       _apiBaseUrl = apiBaseUrl,
       _useGoogle = useGoogle;

  factory ProjectSettings.development() => ProjectSettings(
    isProduction: false,
    apiBaseUrl: 'http://localhost:3000',
    useGoogle: true,
  );

  factory ProjectSettings.production() => ProjectSettings(
    isProduction: true,
    apiBaseUrl: 'http://localhost:3000',
    useGoogle: true,
  );

  final bool _isProduction;
  final String _apiBaseUrl;
  final bool _useGoogle;

  bool get isProduction => _isProduction;
  String get apiBaseUrl => _apiBaseUrl;
  bool get useGoogle => _useGoogle;
}
