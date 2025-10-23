import 'package:multiple_result/multiple_result.dart';

import '../../gateway/api_gateway.dart';
import '../../gateway/routes.dart';
import '../fake_server_cache_engine.dart';
import '../fake_server_database.dart';
import '../fake_server_file_storage.dart';

part '__auth_controller.dart';
part '__profile_controller.dart';
part '__document_controller.dart';
part '__trash_controller.dart';
part '__share_controller.dart';

class FakeApiGateway implements ApiGateway {
  FakeApiGateway({
    required this.fakeServerCacheEngine,
    required this.fakeServerDatabase,
    required this.fakeServerFileStorage,
  }) {
    _authController = _AuthController(
      fakeServerCacheEngine: fakeServerCacheEngine,
      fakeServerDatabase: fakeServerDatabase,
    );
  }

  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  late final _AuthController _authController;

  @override
  set authHeaderProvider(Future<String?> Function()? provider) {
    return;
  }

  @override
  set onUnauthorizedResponse(Future<String?> Function()? provider) {
    return;
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> delete(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    // Route to appropriate controller
    // TODO: Implement delete routes in future phases
    return Error(ClientException('DELETE $path not implemented'));
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    // Route to appropriate controller
    // TODO: Implement get routes in future phases
    return Error(ClientException('GET $path not implemented'));
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    // Route to appropriate controller
    // TODO: Implement patch routes in future phases
    return Error(ClientException('PATCH $path not implemented'));
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    // Route to appropriate auth controller
    switch (path) {
      case GatewayRoutes.loginGoogle:
        return await _authController.loginGoogle(data: data ?? {});
      case GatewayRoutes.loginEmail:
        return await _authController.loginEmail(data: data ?? {});
      case GatewayRoutes.registerUser:
        return await _authController.register(data: data ?? {});
      case GatewayRoutes.logout:
        return await _authController.logout();
      case GatewayRoutes.sendEmail:
        return await _authController.sendEmail(data: data ?? {});
      default:
        return Error(ClientException('POST $path not implemented'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    // Route to appropriate controller
    // TODO: Implement put routes in future phases
    return Error(ClientException('PUT $path not implemented'));
  }
}
