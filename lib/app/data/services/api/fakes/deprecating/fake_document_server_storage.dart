import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/services/api/deprecating/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/cache_database.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';

/// Simulates server-side document storage
/// Stores document metadata in-memory and files in temporary directory
/// Shared between DocumentApiClient and TrashApiClient to simulate backend behavior
class FakeDocumentServerStorage {
  FakeDocumentServerStorage({required this.cacheDatabase});

  final CacheDatabase cacheDatabase;

  // In-memory storage for document metadata (simulates database)
  final List<DocumentApiModel> _documents = [];

  /// Initialize storage by populating from cache database
  Future<void> initialize() async {
    final dbDocs = await cacheDatabase.listDocuments();

    if (dbDocs.isError()) return;

    final docs = dbDocs.tryGetSuccess()!.map((d) {
      return DocumentApiModel(
        uuid: d.uuid,
        titulo: d.titulo,
        nomePaciente: d.paciente,
        nomeMedico: d.medico,
        tipoDocumento: d.tipo,
        dataDocumento: d.dataDocumento,
        createdAt: d.createdAt,
        deletedAt: d.deletedAt,
      );
    });

    _documents.clear();
    _documents.addAll(docs);
  }

  /// Store document metadata in the server storage
  Future<Result<void, Exception>> storeDocumentMetadata(
    DocumentApiModel document,
  ) async {
    try {
      _documents.add(document);
      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to store document metadata: $e'));
    }
  }

  /// Store document file in temporary directory (simulates server file storage)
  Future<Result<void, Exception>> storeDocumentFile(
    String uuid,
    File file,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fakeDocsDir = Directory('${tempDir.path}/fake_docs');
      if (!await fakeDocsDir.exists()) {
        await fakeDocsDir.create(recursive: true);
      }

      final destinationPath = '${fakeDocsDir.path}/$uuid';
      await file.copy(destinationPath);

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to store document file: $e'));
    }
  }

  /// Query all non-deleted documents
  Future<Result<List<DocumentApiModel>, Exception>> queryDocumentList() async {
    try {
      final activeDocuments = _documents
          .where((doc) => doc.deletedAt == null)
          .toList();
      return Success(activeDocuments);
    } catch (e) {
      return Error(Exception('Failed to query document list: $e'));
    }
  }

  /// Query all deleted documents (for trash)
  Future<Result<List<DocumentApiModel>, Exception>>
  queryDeletedDocumentList() async {
    try {
      final deletedDocuments = _documents
          .where((doc) => doc.deletedAt != null)
          .toList();
      return Success(deletedDocuments);
    } catch (e) {
      return Error(Exception('Failed to query deleted document list: $e'));
    }
  }

  /// Query document file by UUID
  Future<Result<Uint8List, Exception>> queryDocumentFile(String uuid) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fake_docs/$uuid');

      if (!await file.exists()) {
        return Error(Exception('Document file not found'));
      }

      final bytes = await file.readAsBytes();
      return Success(bytes);
    } catch (e) {
      return Error(Exception('Failed to query document file: $e'));
    }
  }

  /// Query non-deleted document metadata by UUID
  /// Returns error if document is deleted or not found
  Future<Result<DocumentApiModel, Exception>> queryDocumentMetadata(
    String uuid,
  ) async {
    try {
      final document = _documents.firstWhere(
        (doc) => doc.uuid == uuid,
        orElse: () => throw Exception('Document not found'),
      );

      if (document.deletedAt != null) {
        return Error(Exception('Document has been deleted'));
      }

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to query document metadata: $e'));
    }
  }

  /// Query deleted document metadata by UUID
  /// Returns error if document is not deleted or not found
  Future<Result<DocumentApiModel, Exception>> queryDeletedDocumentMetadata(
    String uuid,
  ) async {
    try {
      final document = _documents.firstWhere(
        (doc) => doc.uuid == uuid,
        orElse: () => throw Exception('Document not found'),
      );

      if (document.deletedAt == null) {
        return Error(Exception('Document is not in trash'));
      }

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to query deleted document metadata: $e'));
    }
  }

  /// Update document metadata by UUID
  /// Only updates non-deleted documents
  Future<Result<DocumentApiModel, Exception>> updateDocumentMetadata(
    String uuid, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      final document = _documents[index];

      if (document.deletedAt != null) {
        return Error(Exception('Cannot update deleted document'));
      }

      final updatedDocument = document.copyWith(
        titulo: titulo ?? document.titulo,
        nomePaciente: nomePaciente ?? document.nomePaciente,
        nomeMedico: nomeMedico ?? document.nomeMedico,
        tipoDocumento: tipoDocumento ?? document.tipoDocumento,
        dataDocumento: dataDocumento ?? document.dataDocumento,
      );

      _documents[index] = updatedDocument;
      return Success(updatedDocument);
    } catch (e) {
      return Error(Exception('Failed to update document metadata: $e'));
    }
  }

  /// Soft delete a document (move to trash)
  Future<Result<void, Exception>> softDeleteDocument(String uuid) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      final document = _documents[index];
      _documents[index] = document.copyWith(deletedAt: DateTime.now());

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to soft delete document: $e'));
    }
  }

  /// Restore a soft-deleted document from trash
  Future<Result<void, Exception>> restoreDocument(String uuid) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      final document = _documents[index];

      if (document.deletedAt == null) {
        return Error(Exception('Document is not in trash'));
      }

      _documents[index] = document.copyWith(deletedAt: null);

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to restore document: $e'));
    }
  }

  /// Permanently delete a document (remove from storage completely)
  Future<Result<void, Exception>> permanentlyDeleteDocument(String uuid) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      final document = _documents[index];

      if (document.deletedAt == null) {
        return Error(
          Exception('Document must be in trash before permanent deletion'),
        );
      }

      // Remove metadata from storage
      _documents.removeAt(index);

      // Delete the physical file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fake_docs/$uuid');
      if (await file.exists()) {
        await file.delete();
      }

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to permanently delete document: $e'));
    }
  }
}
