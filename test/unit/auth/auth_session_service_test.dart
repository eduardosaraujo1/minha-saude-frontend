import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_service.dart';
import 'package:multiple_result/multiple_result.dart';
import 'dart:async';
import 'dart:convert';

// Mock classes for testing
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockHttpClient extends Mock implements http.Client {}

class MockGoogleAuthService extends Mock implements GoogleAuthService {}

// Mock implementations to test the architecture
class TestAuthSessionService implements AuthSessionService {
  final FlutterSecureStorage _secureStorage;
  final http.Client _httpClient;
  final GoogleAuthService _googleAuthService;
  final AuthApiService _authApiService;

  AuthState _state = AuthState.initial;
  AuthUser? _currentUser;
  String? _sessionToken;

  final StreamController<AuthState> _stateController =
      StreamController<AuthState>.broadcast();

  TestAuthSessionService({
    required FlutterSecureStorage secureStorage,
    required http.Client httpClient,
    required GoogleAuthService googleAuthService,
    required AuthApiService authApiService,
  }) : _secureStorage = secureStorage,
       _httpClient = httpClient,
       _googleAuthService = googleAuthService,
       _authApiService = authApiService;

  @override
  AuthState get state => _state;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  String? get sessionToken => _sessionToken;

  @override
  Stream<AuthState> get authStateChanges => _stateController.stream;

  void _setState(AuthState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final storedToken = await _secureStorage.read(key: 'session_token');
      final storedUserData = await _secureStorage.read(key: 'user_data');

      if (storedToken != null && storedUserData != null) {
        final isValid = await _validateToken(storedToken);
        if (isValid) {
          _sessionToken = storedToken;
          _currentUser = AuthUser.fromJson(jsonDecode(storedUserData));
          _setState(AuthState.authenticated);
          return;
        } else {
          await _clearStoredData();
        }
      }

      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setState(AuthState.unauthenticated);
    }
  }

  @override
  Future<Result<AuthUser, Exception>> signInWithGoogle() async {
    _setState(AuthState.loading);

    try {
      final authCodeResult = await _googleAuthService.generateServerAuthCode();
      if (authCodeResult.isError()) {
        _setState(AuthState.unauthenticated);
        return Result.error(authCodeResult.tryGetError()!);
      }

      final serverAuthCode = authCodeResult.getOrThrow();
      final exchangeResult = await _authApiService.exchangeGoogleToken(
        serverAuthCode!,
      );

      if (exchangeResult.isError()) {
        _setState(AuthState.unauthenticated);
        return Result.error(exchangeResult.tryGetError()!);
      }

      final response = exchangeResult.getOrThrow();
      final sessionToken = response['session_token'] as String;
      final refreshToken = response['refresh_token'] as String;
      final userData = response['user'] as Map<String, dynamic>;

      await _secureStorage.write(key: 'session_token', value: sessionToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));

      _sessionToken = sessionToken;
      _currentUser = AuthUser.fromJson(userData);
      _setState(AuthState.authenticated);

      return Result.success(_currentUser!);
    } catch (e) {
      _setState(AuthState.unauthenticated);
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    if (_sessionToken != null) {
      await _authApiService.revokeSession(_sessionToken!);
    }

    await _clearStoredData();
    _sessionToken = null;
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  @override
  Future<Result<http.Response, Exception>> makeAuthenticatedRequest(
    String url, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
  }) async {
    if (_sessionToken == null) {
      return Result.error(Exception('No session token available'));
    }

    final authHeaders = {
      'Authorization': 'Bearer $_sessionToken',
      'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      http.Response response;
      final uri = Uri.parse(url);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(uri, headers: authHeaders);
          break;
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: authHeaders,
            body: body,
          );
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      if (response.statusCode == 401) {
        // Try to refresh token
        final refreshResult = await refreshSession();
        if (refreshResult.isSuccess()) {
          // Retry with new token
          authHeaders['Authorization'] = 'Bearer $_sessionToken';
          switch (method.toUpperCase()) {
            case 'GET':
              response = await _httpClient.get(uri, headers: authHeaders);
              break;
            case 'POST':
              response = await _httpClient.post(
                uri,
                headers: authHeaders,
                body: body,
              );
              break;
          }
        } else {
          await signOut();
          return Result.error(Exception('Session expired'));
        }
      }

      return Result.success(response);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<bool> hasValidSession() async {
    if (_sessionToken == null) return false;
    return await _validateToken(_sessionToken!);
  }

  @override
  Future<Result<String, Exception>> refreshSession() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return Result.error(Exception('No refresh token available'));
      }

      final result = await _authApiService.refreshToken(refreshToken);
      if (result.isError()) {
        return Result.error(result.tryGetError()!);
      }

      final response = result.getOrThrow();
      final newSessionToken = response['session_token'] as String;

      await _secureStorage.write(key: 'session_token', value: newSessionToken);
      _sessionToken = newSessionToken;

      return Result.success(newSessionToken);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('https://api.example.com/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _clearStoredData() async {
    await _secureStorage.delete(key: 'session_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_data');
  }
}

class TestAuthApiService implements AuthApiService {
  final http.Client _httpClient;

  TestAuthApiService({required http.Client httpClient})
    : _httpClient = httpClient;

  @override
  Future<Result<Map<String, dynamic>, Exception>> exchangeGoogleToken(
    String serverAuthCode,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('https://api.example.com/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'server_auth_code': serverAuthCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.error(
          Exception('Token exchange failed: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('https://api.example.com/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.error(
          Exception('Token refresh failed: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> getUserProfile(
    String sessionToken,
  ) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('https://api.example.com/user/profile'),
        headers: {'Authorization': 'Bearer $sessionToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.error(
          Exception('Failed to get user profile: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void, Exception>> revokeSession(String sessionToken) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('https://api.example.com/auth/revoke'),
        headers: {'Authorization': 'Bearer $sessionToken'},
      );

      if (response.statusCode == 200) {
        return Result.success(null);
      } else {
        return Result.error(
          Exception('Failed to revoke session: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}

// Models that represent the authentication state
class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({required this.id, required this.name, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

enum AuthState { initial, authenticated, unauthenticated, loading }

// The main authentication session service that we want to implement
abstract class AuthSessionService {
  // Current authentication state
  AuthState get state;

  // Current authenticated user (null if not authenticated)
  AuthUser? get currentUser;

  // Session token for API requests
  String? get sessionToken;

  // Stream of authentication state changes
  Stream<AuthState> get authStateChanges;

  // Initialize the service (check for existing session)
  Future<void> initialize();

  // Sign in with Google OAuth
  Future<Result<AuthUser, Exception>> signInWithGoogle();

  // Sign out (clear session and user data)
  Future<void> signOut();

  // Make authenticated HTTP requests to the backend
  Future<Result<http.Response, Exception>> makeAuthenticatedRequest(
    String url, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
  });

  // Check if user has a valid session
  Future<bool> hasValidSession();

  // Refresh session token if needed
  Future<Result<String, Exception>> refreshSession();
}

// Backend API service for authentication
abstract class AuthApiService {
  // Exchange Google OAuth code for session token
  Future<Result<Map<String, dynamic>, Exception>> exchangeGoogleToken(
    String serverAuthCode,
  );

  // Refresh session token
  Future<Result<Map<String, dynamic>, Exception>> refreshToken(
    String refreshToken,
  );

  // Get user profile
  Future<Result<Map<String, dynamic>, Exception>> getUserProfile(
    String sessionToken,
  );

  // Revoke session
  Future<Result<void, Exception>> revokeSession(String sessionToken);
}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockHttpClient mockHttpClient;
  late MockGoogleAuthService mockGoogleAuthService;
  late AuthSessionService authSessionService;
  late AuthApiService authApiService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockHttpClient = MockHttpClient();
    mockGoogleAuthService = MockGoogleAuthService();

    authApiService = TestAuthApiService(httpClient: mockHttpClient);
    authSessionService = TestAuthSessionService(
      secureStorage: mockSecureStorage,
      httpClient: mockHttpClient,
      googleAuthService: mockGoogleAuthService,
      authApiService: authApiService,
    );
  });

  group('AuthSessionService', () {
    group('initialization', () {
      test('should start with initial state', () {
        // The service should start in initial state
        expect(authSessionService.state, equals(AuthState.initial));
        expect(authSessionService.currentUser, isNull);
        expect(authSessionService.sessionToken, isNull);
      });

      test(
        'should restore session from secure storage on initialize',
        () async {
          // Arrange
          const storedToken = 'stored_session_token';

          when(
            () => mockSecureStorage.read(key: 'session_token'),
          ).thenAnswer((_) async => storedToken);
          when(() => mockSecureStorage.read(key: 'user_data')).thenAnswer(
            (_) async =>
                '{"id":"123","name":"John Doe","email":"john@example.com"}',
          );

          // Mock successful token validation
          when(
            () => mockHttpClient.get(
              Uri.parse('https://api.example.com/auth/validate'),
              headers: {'Authorization': 'Bearer $storedToken'},
            ),
          ).thenAnswer((_) async => http.Response('{"valid": true}', 200));

          // Act
          await authSessionService.initialize();

          // Assert
          expect(authSessionService.state, equals(AuthState.authenticated));
          expect(authSessionService.currentUser?.id, equals('123'));
          expect(authSessionService.sessionToken, equals(storedToken));
        },
      );

      test('should clear invalid session on initialize', () async {
        // Arrange
        const invalidToken = 'invalid_session_token';

        when(
          () => mockSecureStorage.read(key: 'session_token'),
        ).thenAnswer((_) async => invalidToken);
        when(() => mockSecureStorage.read(key: 'user_data')).thenAnswer(
          (_) async =>
              '{"id":"123","name":"John Doe","email":"john@example.com"}',
        );

        // Mock failed token validation
        when(
          () => mockHttpClient.get(
            Uri.parse('https://api.example.com/auth/validate'),
            headers: {'Authorization': 'Bearer $invalidToken'},
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "Invalid token"}', 401),
        );

        // Act
        await authSessionService.initialize();

        // Assert
        expect(authSessionService.state, equals(AuthState.unauthenticated));
        expect(authSessionService.currentUser, isNull);
        expect(authSessionService.sessionToken, isNull);
        verify(() => mockSecureStorage.delete(key: 'session_token')).called(1);
        verify(() => mockSecureStorage.delete(key: 'user_data')).called(1);
      });
    });

    group('Google Sign In', () {
      test('should successfully sign in with Google and store session', () async {
        // Arrange
        const googleServerAuthCode = 'google_server_auth_code';
        const sessionToken = 'new_session_token';
        const refreshToken = 'refresh_token';
        const userData = {
          'id': '123',
          'name': 'John Doe',
          'email': 'john@example.com',
        };

        // Mock Google auth service
        when(
          () => mockGoogleAuthService.generateServerAuthCode(),
        ).thenAnswer((_) async => Result.success(googleServerAuthCode));

        // Mock backend token exchange
        when(
          () => mockHttpClient.post(
            Uri.parse('https://api.example.com/auth/google'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            '{"session_token": "$sessionToken", "refresh_token": "$refreshToken", "user": ${userData.toString().replaceAll("'", '"')}}',
            200,
          ),
        );

        // Mock secure storage
        when(
          () => mockSecureStorage.write(
            key: 'session_token',
            value: sessionToken,
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.write(
            key: 'refresh_token',
            value: refreshToken,
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.write(
            key: 'user_data',
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await authSessionService.signInWithGoogle();

        // Assert
        expect(result.isSuccess(), isTrue);
        final user = result.getOrThrow();
        expect(user.id, equals('123'));
        expect(user.name, equals('John Doe'));
        expect(user.email, equals('john@example.com'));

        expect(authSessionService.state, equals(AuthState.authenticated));
        expect(authSessionService.currentUser, equals(user));
        expect(authSessionService.sessionToken, equals(sessionToken));

        verify(
          () => mockSecureStorage.write(
            key: 'session_token',
            value: sessionToken,
          ),
        ).called(1);
        verify(
          () => mockSecureStorage.write(
            key: 'refresh_token',
            value: refreshToken,
          ),
        ).called(1);
      });

      test('should handle Google sign in failure', () async {
        // Arrange
        final googleError = Exception('Google sign in failed');
        when(
          () => mockGoogleAuthService.generateServerAuthCode(),
        ).thenAnswer((_) async => Result.error(googleError));

        // Act
        final result = await authSessionService.signInWithGoogle();

        // Assert
        expect(result.isError(), isTrue);
        expect(result.tryGetError(), equals(googleError));
        expect(authSessionService.state, equals(AuthState.unauthenticated));
      });

      test('should handle backend token exchange failure', () async {
        // Arrange
        const googleServerAuthCode = 'google_server_auth_code';

        when(
          () => mockGoogleAuthService.generateServerAuthCode(),
        ).thenAnswer((_) async => Result.success(googleServerAuthCode));

        when(
          () => mockHttpClient.post(
            Uri.parse('https://api.example.com/auth/google'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "Invalid auth code"}', 400),
        );

        // Act
        final result = await authSessionService.signInWithGoogle();

        // Assert
        expect(result.isError(), isTrue);
        expect(authSessionService.state, equals(AuthState.unauthenticated));
      });
    });

    group('Sign Out', () {
      test('should clear session and user data on sign out', () async {
        // Arrange - assume user is already signed in
        const sessionToken = 'current_session_token';

        when(
          () => mockHttpClient.post(
            Uri.parse('https://api.example.com/auth/revoke'),
            headers: {'Authorization': 'Bearer $sessionToken'},
          ),
        ).thenAnswer((_) async => http.Response('{"success": true}', 200));

        when(
          () => mockSecureStorage.delete(key: 'session_token'),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.delete(key: 'refresh_token'),
        ).thenAnswer((_) async {});
        when(
          () => mockSecureStorage.delete(key: 'user_data'),
        ).thenAnswer((_) async {});

        // Act
        await authSessionService.signOut();

        // Assert
        expect(authSessionService.state, equals(AuthState.unauthenticated));
        expect(authSessionService.currentUser, isNull);
        expect(authSessionService.sessionToken, isNull);

        verify(() => mockSecureStorage.delete(key: 'session_token')).called(1);
        verify(() => mockSecureStorage.delete(key: 'refresh_token')).called(1);
        verify(() => mockSecureStorage.delete(key: 'user_data')).called(1);
      });
    });

    group('Authenticated Requests', () {
      test(
        'should make authenticated HTTP requests with session token',
        () async {
          // Arrange
          const sessionToken = 'valid_session_token';
          const responseBody = '{"data": "test"}';

          when(
            () => mockHttpClient.get(
              Uri.parse('https://api.example.com/data'),
              headers: {
                'Authorization': 'Bearer $sessionToken',
                'Content-Type': 'application/json',
              },
            ),
          ).thenAnswer((_) async => http.Response(responseBody, 200));

          // Act
          final result = await authSessionService.makeAuthenticatedRequest(
            'https://api.example.com/data',
          );

          // Assert
          expect(result.isSuccess(), isTrue);
          final response = result.getOrThrow();
          expect(response.statusCode, equals(200));
          expect(response.body, equals(responseBody));
        },
      );

      test(
        'should refresh token automatically when request returns 401',
        () async {
          // Arrange
          const oldSessionToken = 'expired_session_token';
          const newSessionToken = 'refreshed_session_token';
          const refreshToken = 'refresh_token';

          // First request fails with 401
          when(
            () => mockHttpClient.get(
              Uri.parse('https://api.example.com/data'),
              headers: {
                'Authorization': 'Bearer $oldSessionToken',
                'Content-Type': 'application/json',
              },
            ),
          ).thenAnswer(
            (_) async => http.Response('{"error": "Unauthorized"}', 401),
          );

          // Mock refresh token request
          when(
            () => mockSecureStorage.read(key: 'refresh_token'),
          ).thenAnswer((_) async => refreshToken);

          when(
            () => mockHttpClient.post(
              Uri.parse('https://api.example.com/auth/refresh'),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer(
            (_) async =>
                http.Response('{"session_token": "$newSessionToken"}', 200),
          );

          // Second request with new token succeeds
          when(
            () => mockHttpClient.get(
              Uri.parse('https://api.example.com/data'),
              headers: {
                'Authorization': 'Bearer $newSessionToken',
                'Content-Type': 'application/json',
              },
            ),
          ).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

          when(
            () => mockSecureStorage.write(
              key: 'session_token',
              value: newSessionToken,
            ),
          ).thenAnswer((_) async {});

          // Act
          final result = await authSessionService.makeAuthenticatedRequest(
            'https://api.example.com/data',
          );

          // Assert
          expect(result.isSuccess(), isTrue);
          expect(authSessionService.sessionToken, equals(newSessionToken));
          verify(
            () => mockSecureStorage.write(
              key: 'session_token',
              value: newSessionToken,
            ),
          ).called(1);
        },
      );

      test('should sign out user when refresh token is invalid', () async {
        // Arrange
        const oldSessionToken = 'expired_session_token';
        const refreshToken = 'invalid_refresh_token';

        // First request fails with 401
        when(
          () => mockHttpClient.get(
            Uri.parse('https://api.example.com/data'),
            headers: {
              'Authorization': 'Bearer $oldSessionToken',
              'Content-Type': 'application/json',
            },
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "Unauthorized"}', 401),
        );

        // Mock refresh token request fails
        when(
          () => mockSecureStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => refreshToken);

        when(
          () => mockHttpClient.post(
            Uri.parse('https://api.example.com/auth/refresh'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"error": "Invalid refresh token"}', 401),
        );

        when(
          () => mockSecureStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        // Act
        final result = await authSessionService.makeAuthenticatedRequest(
          'https://api.example.com/data',
        );

        // Assert
        expect(result.isError(), isTrue);
        expect(authSessionService.state, equals(AuthState.unauthenticated));
        expect(authSessionService.sessionToken, isNull);
      });
    });

    group('Session Validation', () {
      test('should return true for valid session', () async {
        // Arrange
        const sessionToken = 'valid_session_token';

        when(
          () => mockHttpClient.get(
            Uri.parse('https://api.example.com/auth/validate'),
            headers: {'Authorization': 'Bearer $sessionToken'},
          ),
        ).thenAnswer((_) async => http.Response('{"valid": true}', 200));

        // Act
        final isValid = await authSessionService.hasValidSession();

        // Assert
        expect(isValid, isTrue);
      });

      test('should return false for invalid session', () async {
        // Arrange
        const sessionToken = 'invalid_session_token';

        when(
          () => mockHttpClient.get(
            Uri.parse('https://api.example.com/auth/validate'),
            headers: {'Authorization': 'Bearer $sessionToken'},
          ),
        ).thenAnswer((_) async => http.Response('{"valid": false}', 401));

        // Act
        final isValid = await authSessionService.hasValidSession();

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('State Changes', () {
      test('should emit state changes through stream', () async {
        // This test would verify that the authStateChanges stream
        // emits the correct states when authentication state changes

        // Arrange
        final stateChanges = <AuthState>[];
        authSessionService.authStateChanges.listen((state) {
          stateChanges.add(state);
        });

        // Act & Assert would test various state transitions
        // Example: signIn -> loading -> authenticated
        // signOut -> loading -> unauthenticated

        expect(stateChanges, isNotEmpty);
      });
    });
  });

  group('AuthApiService', () {
    test('should exchange Google token for session token', () async {
      // Arrange
      const serverAuthCode = 'google_server_auth_code';

      when(
        () => mockHttpClient.post(
          Uri.parse('https://api.example.com/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: '{"server_auth_code": "$serverAuthCode"}',
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"session_token": "session_token", "refresh_token": "refresh_token", "user": {"id": "123", "name": "John Doe", "email": "john@example.com"}}',
          200,
        ),
      );

      // Act
      final result = await authApiService.exchangeGoogleToken(serverAuthCode);

      // Assert
      expect(result.isSuccess(), isTrue);
      final response = result.getOrThrow();
      expect(response['session_token'], equals('session_token'));
      expect(response['user']['id'], equals('123'));
    });

    test('should refresh session token', () async {
      // Arrange
      const refreshToken = 'refresh_token';

      when(
        () => mockHttpClient.post(
          Uri.parse('https://api.example.com/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: '{"refresh_token": "$refreshToken"}',
        ),
      ).thenAnswer(
        (_) async =>
            http.Response('{"session_token": "new_session_token"}', 200),
      );

      // Act
      final result = await authApiService.refreshToken(refreshToken);

      // Assert
      expect(result.isSuccess(), isTrue);
      final response = result.getOrThrow();
      expect(response['session_token'], equals('new_session_token'));
    });

    test('should get user profile', () async {
      // Arrange
      const sessionToken = 'session_token';

      when(
        () => mockHttpClient.get(
          Uri.parse('https://api.example.com/user/profile'),
          headers: {'Authorization': 'Bearer $sessionToken'},
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id": "123", "name": "John Doe", "email": "john@example.com"}',
          200,
        ),
      );

      // Act
      final result = await authApiService.getUserProfile(sessionToken);

      // Assert
      expect(result.isSuccess(), isTrue);
      final profile = result.getOrThrow();
      expect(profile['id'], equals('123'));
      expect(profile['name'], equals('John Doe'));
    });

    test('should revoke session', () async {
      // Arrange
      const sessionToken = 'session_token';

      when(
        () => mockHttpClient.post(
          Uri.parse('https://api.example.com/auth/revoke'),
          headers: {'Authorization': 'Bearer $sessionToken'},
        ),
      ).thenAnswer((_) async => http.Response('{"success": true}', 200));

      // Act
      final result = await authApiService.revokeSession(sessionToken);

      // Assert
      expect(result.isSuccess(), isTrue);
    });
  });
}
