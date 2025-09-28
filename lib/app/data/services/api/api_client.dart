import 'package:dio/dio.dart';
import 'package:minha_saude_frontend/app/data/services/api/exceptions/bad_response_exception.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_response.dart';
import 'package:multiple_result/multiple_result.dart';

typedef AuthHeaderProvider = Future<String?> Function();

class ApiClient {
  ApiClient(Dio dio, String baseUrl) : _dio = dio {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Accept': 'application/json'};
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authHeaderProvider != null) {
            final authHeader = await _authHeaderProvider!.call();
            options.headers['Authorization'] = 'Bearer $authHeader';
          }
          return handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  AuthHeaderProvider? _authHeaderProvider;

  set authHeaderProvider(AuthHeaderProvider provider) {
    _authHeaderProvider = provider;
  }

  /// Login with Google server code
  Future<Result<LoginResponse, Exception>> loginWithGoogle(
    String serverAuthCode,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/google/login',
        data: {'serverAuthCode': serverAuthCode},
      );

      // Early return for non-200 status codes
      if (response.statusCode != 200) {
        return Result.error(
          BadResponseException(
            'Login failed: ${response.statusMessage ?? 'Unknown error'}',
          ),
        );
      }

      // Early return for null response data
      if (response.data == null) {
        return Result.error(
          BadResponseException('Login failed: Server returned empty response'),
        );
      }

      // Early return for invalid response format
      if (response.data is! Map<String, dynamic>) {
        return Result.error(
          BadResponseException(
            'Login failed: Server returned invalid response format',
          ),
        );
      }

      final loginResponse = LoginResponse.fromJson(response.data);
      return Result.success(loginResponse);
    } on DioException {
      return Result.error(
        BadResponseException('Login failed: Unable to connect to server'),
      );
    } catch (e) {
      // This catches JSON parsing errors or missing required fields
      return Result.error(
        BadResponseException(
          'Login failed: Server response format has changed or is invalid',
        ),
      );
    }
  }

  /// Signout
  Future<Result<void, Exception>> signOut() async {
    try {
      await _dio.post('/auth/signout');
      return Result.success(null);
    } on DioException {
      return Result.error(
        BadResponseException('Sign out failed: Unable to connect to server'),
      );
    }
  }
}
