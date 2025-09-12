class AuthCacheService {
  AuthCacheService();

  // Stored token
  String? _token;

  // Stored registration status
  bool? _isRegistered;

  bool get isLoggedIn => _token == null;
  bool get hasToken => _token != null;

  bool get isRegistered => _isRegistered ?? false;
  String? get token => _token;

  bool getIsRegistered() {
    return _isRegistered ?? false;
  }

  /// Set session token to local storage
  void setToken(String token) async {
    _token = token;
  }

  void setRegistered(bool isRegistered) {
    _isRegistered = isRegistered;
  }

  /// Remove session token from local storage
  void clearCache() async {
    _token = null;
    _isRegistered = null;
  }
}
