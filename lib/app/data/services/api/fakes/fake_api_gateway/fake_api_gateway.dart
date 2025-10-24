import 'package:multiple_result/multiple_result.dart';

import '../../gateway/api_gateway.dart';
import '../../gateway/gateway_routes.dart';
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
    _profileController = _ProfileController(
      fakeServerDatabase: fakeServerDatabase,
      fakeServerCacheEngine: fakeServerCacheEngine,
    );
    _documentController = _DocumentController(
      fakeServerDatabase: fakeServerDatabase,
      fakeServerCacheEngine: fakeServerCacheEngine,
      fakeServerFileStorage: fakeServerFileStorage,
    );
    _trashController = _TrashController(
      fakeServerDatabase: fakeServerDatabase,
      fakeServerCacheEngine: fakeServerCacheEngine,
      fakeServerFileStorage: fakeServerFileStorage,
    );
    _shareController = _ShareController(
      fakeServerDatabase: fakeServerDatabase,
      fakeServerCacheEngine: fakeServerCacheEngine,
      fakeServerFileStorage: fakeServerFileStorage,
    );
  }

  final FakeServerCacheEngine fakeServerCacheEngine;
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  late final _AuthController _authController;
  late final _ProfileController _profileController;
  late final _DocumentController _documentController;
  late final _TrashController _trashController;
  late final _ShareController _shareController;

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
    switch (path) {
      case GatewayRoutes.deleteAccount:
        return await _profileController.deleteAccount(data: data ?? {});
      default:
        // Check if it's a share deletion
        if (path.startsWith('/shares/')) {
          final code = path.replaceFirst('/shares/', '');
          return await _shareController.deleteShare(code: code);
        }
        // Check if it's a document deletion
        if (path.startsWith('/documents/') && !path.contains('/download')) {
          final id = path.replaceFirst('/documents/', '');
          return await _documentController.deleteDocument(id: id);
        }
        return Error(ClientException('DELETE $path not implemented'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, ApiGatewayException>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    // Route to appropriate controller
    switch (path) {
      case GatewayRoutes.getUserProfile:
        return await _profileController.getUserProfile();
      case GatewayRoutes.listDocuments:
        return await _documentController.listDocuments();
      case GatewayRoutes.listCategories:
        return await _documentController.listCategories();
      case GatewayRoutes.listTrash:
        return await _trashController.listTrash();
      case GatewayRoutes.listShares:
        return await _shareController.listShares();
      default:
        // Check if it's a trash-specific GET
        if (path.startsWith('/trash/') &&
            !path.contains('/restore') &&
            !path.contains('/destroy')) {
          final id = path.replaceFirst('/trash/', '');
          return await _trashController.viewTrashDocument(id: id);
        }
        // Check if it's a share-specific GET
        if (path.startsWith('/shares/')) {
          final code = path.replaceFirst('/shares/', '');
          return await _shareController.getShareDetails(code: code);
        }
        // Check if it's a document-specific GET
        if (path.startsWith('/documents/')) {
          if (path.endsWith('/download')) {
            final id = path
                .replaceFirst('/documents/', '')
                .replaceFirst('/download', '');
            return await _documentController.downloadDocument(id: id);
          } else {
            final id = path.replaceFirst('/documents/', '');
            return await _documentController.getDocument(id: id);
          }
        }
        return Error(ClientException('GET $path not implemented'));
    }
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
    // Route to appropriate controller
    switch (path) {
      // Auth routes
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

      // Profile routes
      case GatewayRoutes.sendPhoneSms:
        return await _profileController.sendPhoneSms(data: data ?? {});
      case GatewayRoutes.linkGoogleAccount:
        return await _profileController.linkGoogleAccount(data: data ?? {});

      // Document routes
      case GatewayRoutes.uploadDocument:
        return await _documentController.uploadDocument(data: data ?? {});

      // Share routes
      case GatewayRoutes.createShare:
        return await _shareController.createShare(data: data ?? {});

      default:
        // Check if it's a trash restore/destroy operation
        if (path.contains('/trash/')) {
          if (path.endsWith('/restore')) {
            final id = path
                .replaceFirst('/trash/', '')
                .replaceFirst('/restore', '');
            return await _trashController.restoreTrashDocument(id: id);
          } else if (path.endsWith('/destroy')) {
            final id = path
                .replaceFirst('/trash/', '')
                .replaceFirst('/destroy', '');
            return await _trashController.destroyTrashDocument(id: id);
          }
        }
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
    switch (path) {
      case GatewayRoutes.editName:
        return await _profileController.editName(data: data ?? {});
      case GatewayRoutes.editBirthdate:
        return await _profileController.editBirthdate(data: data ?? {});
      case GatewayRoutes.editPhone:
        return await _profileController.editPhone(data: data ?? {});
      default:
        // Check if it's a document metadata edit
        if (path.startsWith('/documents/') && !path.contains('/download')) {
          final id = path.replaceFirst('/documents/', '');
          return await _documentController.editMetadata(
            id: id,
            data: data ?? {},
          );
        }
        return Error(ClientException('PUT $path not implemented'));
    }
  }
}
