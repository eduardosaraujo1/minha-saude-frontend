part of '../gateway/api_gateway.dart';

class FakeApiGateway implements ApiGateway {
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
  Future<Result<Map<String, dynamic>, ApiGatewayException>> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> get(
    String path, {
    Map<String, String>? headers,
  }) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    // TODO: implement put
    throw UnimplementedError();
  }
}
