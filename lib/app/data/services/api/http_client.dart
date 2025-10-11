import 'package:dio/dio.dart';

typedef AuthHeaderProvider = Future<String?> Function();

class HttpClient {
  HttpClient({
    required String baseUrl,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, dynamic>? defaultHeaders,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout;

    final headers = <String, dynamic>{'Accept': 'application/json'};
    if (defaultHeaders != null && defaultHeaders.isNotEmpty) {
      headers.addAll(defaultHeaders);
    }
    _dio.options.headers = headers;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_authHeaderProvider != null) {
            final authHeader = await _authHeaderProvider!.call();
            if (authHeader != null && authHeader.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $authHeader';
            } else {
              options.headers.remove('Authorization');
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  AuthHeaderProvider? _authHeaderProvider;

  Dio get dio => _dio;

  set authHeaderProvider(AuthHeaderProvider? provider) {
    _authHeaderProvider = provider;
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void updateTimeouts({Duration? connectTimeout, Duration? receiveTimeout}) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
  }
}
