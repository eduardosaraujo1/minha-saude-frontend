import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../app/data/services/api/api_client.dart';
import '../../../../app/data/services/api/exceptions/bad_response_exception.dart';
import '../../../../app/data/services/api/models/login_response/login_api_response.dart';
import '../../../../app/data/services/api/models/register_response/register_response.dart';
import '../../../../app/domain/models/user_register_model/user_register_model.dart';

class ApiClientImpl implements ApiClient {
  ApiClientImpl(Dio dio, String baseUrl) : _dio = dio {
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

  @override
  set authHeaderProvider(AuthHeaderProvider provider) {
    _authHeaderProvider = provider;
  }

  /// Login with Google server code
  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login/google',
        data: {'tokenOauth': tokenOauth},
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

      final loginResponse = LoginApiResponse.fromJson(response.data);
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
  @override
  Future<Result<void, Exception>> authLogout() async {
    try {
      await _dio.post('/auth/logout');
      return Result.success(null);
    } on DioException {
      return Result.error(
        BadResponseException('Sign out failed: Unable to connect to server'),
      );
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> authRegister(
    UserRegisterModel data,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<String, Exception>> authSendEmail(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginEmail(
    String email,
    String code,
  ) async {
    // TODO: implement authLoginEmail
    throw UnimplementedError();
  }
}
