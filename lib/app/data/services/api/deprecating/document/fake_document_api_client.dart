import 'dart:io';
import 'dart:typed_data';

import 'package:multiple_result/multiple_result.dart';
import 'package:uuid/uuid.dart';

import '../../fakes/deprecating/fake_document_server_storage.dart';
import 'document_api_client.dart';
import 'models/document_api_model.dart';

/// Fake implementation of DocumentApiClient for testing/development
/// Simulates backend API behavior using FakeDocumentServerStorage
class FakeDocumentApiClient implements DocumentApiClient {
  FakeDocumentApiClient({required this.serverStorage});

  // Server-side storage (simulates backend)
  final FakeDocumentServerStorage serverStorage;

  // UUID generator (simulates server-side UUID generation)
  final _uuid = const Uuid();

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      return await serverStorage.softDeleteDocument(uuid);
    } catch (e) {
      return Error(Exception('Failed to delete document: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> uploadDocument({
    required File file,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    try {
      // Simulate network delay (longer for file upload)
      await Future.delayed(const Duration(milliseconds: 1200));

      // Generate new UUID (simulates server-side generation)
      final uuid = _uuid.v4();

      // Create document metadata
      final document = DocumentApiModel(
        uuid: uuid,
        titulo: titulo ?? 'Documento sem título',
        nomePaciente: nomePaciente,
        nomeMedico: nomeMedico,
        tipoDocumento: tipoDocumento,
        dataDocumento: dataDocumento,
        createdAt: DateTime.now(),
      );

      // Store file in server storage
      final fileResult = await serverStorage.storeDocumentFile(uuid, file);
      if (fileResult.isError()) {
        return Error(fileResult.tryGetError()!);
      }

      // Store metadata in server storage
      final metadataResult = await serverStorage.storeDocumentMetadata(
        document,
      );
      if (metadataResult.isError()) {
        return Error(metadataResult.tryGetError()!);
      }

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to upload document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listDocuments() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      return await serverStorage.queryDocumentList();
    } catch (e) {
      return Error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<Uint8List, Exception>> downloadDocument(String uuid) async {
    try {
      // Simulate network delay (longer for file download)
      await Future.delayed(const Duration(milliseconds: 1000));

      // Verify document exists and is not deleted
      final metadataResult = await serverStorage.queryDocumentMetadata(uuid);
      if (metadataResult.isError()) {
        return Error(metadataResult.tryGetError()!);
      }

      // Query file from server storage
      return await serverStorage.queryDocumentFile(uuid);
    } catch (e) {
      return Error(Exception('Failed to download document: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocument(String uuid) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));

      // Query document metadata from server storage
      // This endpoint returns metadata even if document is deleted (matches API spec)
      return await serverStorage.queryDocumentMetadata(uuid);
    } catch (e) {
      return Error(Exception('Failed to get document metadata: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String uuid, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 700));

      // Update metadata in server storage
      return await serverStorage.updateDocumentMetadata(
        uuid,
        titulo: titulo,
        nomePaciente: nomePaciente,
        nomeMedico: nomeMedico,
        tipoDocumento: tipoDocumento,
        dataDocumento: dataDocumento,
      );
    } catch (e) {
      return Error(Exception('Failed to update document: $e'));
    }
  }
}
