import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository.dart';

class ApiClient {
  final Dio _httpClient;
  final TokenRepository _tokenRepository;

  // Class that handles communication with backend server
  // Has endpoint url, and handles middleware like signing out on 401 Unauthorized error
  // Simple abstraction such as get, post, put, delete methods
  // Is NOT a singleton, can be instantiated normally but it made a singleton in get_it.dart

  ApiClient(this._httpClient, this._tokenRepository) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor to add auth token
    _httpClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header if we have a token
          final token = await _tokenRepository.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // TODO: If server responds with 401 Unauthorized or specific logout signal,
          // automatically clear local auth data by calling:
          // await _tokenRepository.removeToken();
          // This would handle cases like token expiration or forced logout

          if (error.response?.statusCode == 401) {
            // Future feature: Auto-logout on 401
            log(
              "Warning: Received 401 Unauthorized. Consider implementing auto-logout.",
            );
          }

          handler.next(error);
        },
      ),
    );
  }

  // Simple HTTP methods that use the configured Dio instance
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _httpClient.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _httpClient.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _httpClient.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _httpClient.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
