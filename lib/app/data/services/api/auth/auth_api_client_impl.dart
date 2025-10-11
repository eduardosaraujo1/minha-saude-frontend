import 'package:dio/dio.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/auth_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/models/login_response/login_api_response.dart';
import 'package:minha_saude_frontend/app/data/services/api/auth/models/register_response/register_response.dart';
import 'package:minha_saude_frontend/app/data/services/api/exceptions/bad_response_exception.dart';
import 'package:minha_saude_frontend/app/data/services/api/http_client.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/user_register_model/user_register_model.dart';
import 'package:multiple_result/multiple_result.dart';

class AuthApiClientImpl implements AuthApiClient {
  AuthApiClientImpl(HttpClient httpClient) : _httpClient = httpClient;

  final HttpClient _httpClient;

  /// Login with Google server code
  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    try {
      final response = await _httpClient.dio.post(
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
      await _httpClient.dio.post('/auth/logout');
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
