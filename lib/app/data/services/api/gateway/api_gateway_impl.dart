part of 'api_gateway.dart';

class ApiGatewayImpl implements ApiGateway {
  ApiGatewayImpl();

  Future<String?> Function()? _authHeaderProvider;

  Future<String?> Function()? _onUnauthorizedResponse;

  @override
  set authHeaderProvider(Future<String?> Function()? provider) {
    _authHeaderProvider = provider;
  }

  @override
  set onUnauthorizedResponse(Future<String?> Function()? provider) {
    _onUnauthorizedResponse = provider;
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUrl(path);
      final finalHeaders = await _appendDefaultHeaders(headers);
      final body = data != null ? json.encode(data) : null;

      final response = await http.post(uri, headers: finalHeaders, body: body);

      return _handleResponse(response);
    } catch (e) {
      return Error(ClientException('POST request failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUrl(path);
      final finalHeaders = await _appendDefaultHeaders(headers);

      final response = await http.get(uri, headers: finalHeaders);

      return _handleResponse(response);
    } catch (e) {
      return Error(ClientException('GET request failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUrl(path);
      final finalHeaders = await _appendDefaultHeaders(headers);
      final body = data != null ? json.encode(data) : null;

      final response = await http.put(uri, headers: finalHeaders, body: body);

      return _handleResponse(response);
    } catch (e) {
      return Error(ClientException('PUT request failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUrl(path);
      final finalHeaders = await _appendDefaultHeaders(headers);
      final body = data != null ? json.encode(data) : null;

      final response = await http.patch(uri, headers: finalHeaders, body: body);

      return _handleResponse(response);
    } catch (e) {
      return Error(ClientException('PATCH request failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUrl(path);
      final finalHeaders = await _appendDefaultHeaders(headers);
      final body = data != null ? json.encode(data) : null;

      final response = await http.delete(
        uri,
        headers: finalHeaders,
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      return Error(ClientException('DELETE request failed: $e'));
    }
  }

  Future<Result<Map<String, dynamic>, ApiGatewayException>> _handleResponse(
    Response response,
  ) async {
    final httpError = await _processResponseErrors(response);
    if (httpError != null) {
      return Error(httpError);
    }

    final (:success, :error) = _parseJsonResponse(response.body).getBoth();

    if (error != null) {
      return Error(ClientException('Failed to parse response JSON: $error'));
    }

    return Success(success!);
  }

  Result<Map<String, dynamic>, Exception> _parseJsonResponse(
    String responseBody,
  ) {
    try {
      return Success(json.decode(responseBody) as Map<String, dynamic>);
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Uri _buildUrl(String path) {
    return Uri.parse('${Environment.apiUrl}/$path');
  }

  Future<Map<String, String>> _appendDefaultHeaders(
    Map<String, String>? headers,
  ) async {
    final Map<String, String> defaultHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Append Authorization header if available
    final authToken = await _authHeaderProvider?.call();

    if (authToken != null && authToken.isNotEmpty) {
      defaultHeaders['Authorization'] = 'Bearer $authToken';
    }

    // Append custom headers
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }

  Future<ApiGatewayException?> _processResponseErrors(Response response) async {
    // Handle client exceptions
    if (response.statusCode >= 400 && response.statusCode < 500) {
      // Trigger unauthorized handler if 401
      if (response.statusCode == 401 && _onUnauthorizedResponse != null) {
        await _onUnauthorizedResponse!();
      }

      return ClientException(
        'Client error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }

    if (response.statusCode >= 500) {
      return ServerException(
        'Server error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }

    return null;
  }
}
