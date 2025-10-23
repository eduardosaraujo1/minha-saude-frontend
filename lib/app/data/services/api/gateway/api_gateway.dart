import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:multiple_result/multiple_result.dart';

import '../../../../../config/environment.dart';

part 'api_gateway_impl.dart';

typedef Response = http.Response;

/// API Gateway abstraction for making HTTP requests.
///
/// ALWAYS returns a JSON response body parsed as Map\<String, dynamic\>.
abstract class ApiGateway {
  /// Sends a POST request to the specified [path] with optional [data] and [headers].
  ///
  /// By default uses Authorization headers from [authHeaderProvider].
  ///
  /// Uses [Environment.apiUrl] as base URL.
  ///
  /// Will call [onUnauthorizedResponse] on HTTP 401 Unauthorized responses.
  ///
  /// May return [ApiGatewayException] on failure.
  Future<Result<Map<String, dynamic>, ApiGatewayException>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// Sends a GET request to the specified [path] with optional [headers].
  ///
  /// By default uses Authorization headers from [authHeaderProvider].
  ///
  /// Uses [Environment.apiUrl] as base URL.
  ///
  /// Will call [onUnauthorizedResponse] on HTTP 401 Unauthorized responses.
  ///
  /// May return [ApiGatewayException] on failure.
  Future<Result<Map<String, dynamic>, ApiGatewayException>> get(
    String path, {
    Map<String, String>? headers,
  });

  /// Sends a PUT request to the specified [path] with optional [data] and [headers].
  ///
  /// By default uses Authorization headers from [authHeaderProvider].
  ///
  /// Uses [Environment.apiUrl] as base URL.
  ///
  /// Will call [onUnauthorizedResponse] on HTTP 401 Unauthorized responses.
  ///
  /// May return [ApiGatewayException] on failure.
  Future<Result<Map<String, dynamic>, ApiGatewayException>> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// Sends a PATCH request to the specified [path] with optional [data] and [headers].
  ///
  /// By default uses Authorization headers from [authHeaderProvider].
  ///
  /// Uses [Environment.apiUrl] as base URL.
  ///
  /// Will call [onUnauthorizedResponse] on HTTP 401 Unauthorized responses.
  ///
  /// May return [ApiGatewayException] on failure.
  Future<Result<Map<String, dynamic>, ApiGatewayException>> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// Sends a DELETE request to the specified [path] with optional [data] and [headers].
  ///
  /// By default uses Authorization headers from [authHeaderProvider].
  ///
  /// Uses [Environment.apiUrl] as base URL.
  ///
  /// Will call [onUnauthorizedResponse] on HTTP 401 Unauthorized responses.
  ///
  /// May return [ApiGatewayException] on failure.
  Future<Result<Map<String, dynamic>, ApiGatewayException>> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });

  /// Sets a provider function that returns the authentication header value.
  set authHeaderProvider(Future<String?> Function()? provider);

  /// Called when an HTTP 401 Unauthorized response is received.
  /// The provider can (for example) refresh credentials and return a new auth header value.
  set onUnauthorizedResponse(Future<String?> Function()? provider);
}

abstract class ApiGatewayException implements Exception {
  final String message;

  ApiGatewayException(this.message);

  @override
  String toString() => 'ApiGatewayException: $message';
}

class ClientException extends ApiGatewayException {
  ClientException(super.message);
}

class ServerException extends ApiGatewayException {
  ServerException(super.message);
}
