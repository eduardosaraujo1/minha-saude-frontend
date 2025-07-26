import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/google_sign_config.dart';
import 'package:http/http.dart' as http;
import 'package:minha_saude_frontend/utils/result.dart';

/// The scopes required for getting user info via tokeninfo endpoint
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/userinfo.profile',
  'openid',
];

class GoogleAuthClient {
  GoogleAuthClient() {
    _initClient();
  }

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _errorMessage = '';

  // Getters for accessing current state
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  bool get isSignedIn => _currentUser != null;
  String get errorMessage => _errorMessage;

  void _initClient() {
    _signIn
        .initialize(
          clientId: GoogleSignConfig.clientId,
          serverClientId: GoogleSignConfig.serverClientId,
        )
        .then((_) {
          _signIn.authenticationEvents
              .listen(_handleAuthenticationEvent)
              .onError(_handleAuthenticationError);

          _signIn.attemptLightweightAuthentication();
        })
        .catchError(_handleAuthenticationError);
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);

    _currentUser = user;
    _isAuthorized = authorization != null;
    _errorMessage = '';
  }

  Future<Null> _handleAuthenticationError(Object e) async {
    _currentUser = null;
    _isAuthorized = false;
    _errorMessage = e is GoogleSignInException
        ? _errorMessageFromSignInException(e)
        : 'Unknown error: $e';
  }

  /// Sign in with Google
  Future<Result<GoogleSignInAccount?>> signIn() async {
    if (_signIn.supportsAuthenticate()) {
      try {
        await _signIn.authenticate();
        return Result.ok(_currentUser);
      } catch (e) {
        _errorMessage = e.toString();
        return Result.error(Exception(_errorMessage));
      }
    } else {
      _errorMessage = 'Authentication not supported on this platform';
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Sign out from Google
  Future<Result<void>> signOut() async {
    try {
      await _signIn.disconnect();
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage = '';
      return Result.ok(null);
    } catch (e) {
      _errorMessage = 'Sign-out error: $e';
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Authorize the required scopes for user info access
  Future<Result<bool>> authorizeScopes() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return Result.error(Exception(_errorMessage));
    }

    try {
      await _currentUser!.authorizationClient.authorizeScopes(scopes);

      _isAuthorized = true;
      _errorMessage = '';
      return Result.ok(true);
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
      _isAuthorized = false;
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Get authorization headers for API calls
  Future<Result<Map<String, String>>> getAuthorizationHeaders() async {
    if (_currentUser == null || !_isAuthorized) {
      _errorMessage = 'No user signed in or not authorized';
      return Result.error(Exception(_errorMessage));
    }

    final headers = await _currentUser!.authorizationClient
        .authorizationHeaders(scopes);
    if (headers == null) {
      _errorMessage =
          'Error getting authorization headers, scopes may be unauthorized';
      return Result.error(Exception(_errorMessage));
    }

    return Result.ok(headers);
  }

  /// Get user info from Google's tokeninfo endpoint
  Future<Result<Map<String, dynamic>>> getUserInfoFromTokenInfo() async {
    final headersResult = await getAuthorizationHeaders();
    if (headersResult is Error) {
      return Result.error(Exception(_errorMessage));
    }
    final headers = (headersResult as Ok).value;

    try {
      // Extract the access token from authorization header
      final authHeader = headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        _errorMessage = 'Invalid authorization header';
        return Result.error(Exception(_errorMessage));
      }

      final accessToken = authHeader.substring(7); // Remove "Bearer " prefix

      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$accessToken',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _errorMessage = '';
        return Result.ok(data);
      } else {
        _errorMessage = 'Token validation failed: ${response.statusCode}';
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Error validating token: $e';
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Get user info from Google's userinfo endpoint (alternative method)
  Future<Result<Map<String, dynamic>>> getUserInfoFromUserInfoEndpoint() async {
    final headersResult = await getAuthorizationHeaders();
    if (headersResult is Error) {
      return headersResult;
    }
    final headers = (headersResult as Ok).value;

    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _errorMessage = '';
        return Result.ok(data);
      } else {
        _errorMessage = 'Failed to get user info: ${response.statusCode}';
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Error getting user info: $e';
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Get server auth code (for server-side verification)
  Future<Result<String?>> getServerAuthCode() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return Result.error(Exception(_errorMessage));
    }

    try {
      final GoogleSignInServerAuthorization? serverAuth = await _currentUser!
          .authorizationClient
          .authorizeServer(scopes);

      return Result.ok(serverAuth?.serverAuthCode);
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
      return Result.error(Exception(_errorMessage));
    }
  }

  /// Get basic user information from the GoogleSignInAccount
  Map<String, String?> getBasicUserInfo() {
    if (_currentUser == null) {
      return {};
    }

    return {
      'id': _currentUser!.id,
      'email': _currentUser!.email,
      'displayName': _currentUser!.displayName,
      'photoUrl': _currentUser!.photoUrl,
    };
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}
