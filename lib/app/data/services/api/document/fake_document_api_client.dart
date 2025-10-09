import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/services/cache_database/document_cache_database.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'models/document_api_model.dart';
import 'document_api_client.dart';

/// Fake implementation of DocumentApiClient for testing/development
/// Simulates backend API behavior using in-memory storage and temporary files
class FakeDocumentApiClient implements DocumentApiClient {
  // In-memory storage for document metadata (simulates database)
  final List<DocumentApiModel> _documents = [];

  // UUID generator (simulates server-side UUID generation)
  final _uuid = const Uuid();

  Future<void> populateLocalArrayWithDatabaseData(
    DocumentCacheDatabase db,
  ) async {
    final dbDocs = await db.listDocuments();

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

    // push new stuff
    _documents.clear();
    _documents.addAll(docs);
  }

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) async {
    try {
      // Find the document by ID
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      // Soft delete: update the document with deletedAt timestamp
      final document = _documents[index];
      _documents[index] = document.copyWith(deletedAt: DateTime.now());

      // Delete the physical file from temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fake_docs/${document.uuid}');
      if (await file.exists()) {
        await file.delete();
      }

      return const Success(null);
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
      // Generate new UUID (simulates server-side generation)
      final uuid = _uuid.v4();

      // Copy file to temporary directory (simulates Storage::Laravel facade)
      final tempDir = await getTemporaryDirectory();
      final fakeDocsDir = Directory('${tempDir.path}/fake_docs');
      if (!await fakeDocsDir.exists()) {
        await fakeDocsDir.create(recursive: true);
      }

      final destinationPath = '${fakeDocsDir.path}/$uuid';
      await file.copy(destinationPath);

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

      _documents.add(document);

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to upload document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> listDocuments() async {
    try {
      // Filter out soft-deleted documents
      final activeDocuments = _documents
          .where((doc) => doc.deletedAt == null)
          .toList();

      return Success(activeDocuments);
    } catch (e) {
      return Error(Exception('Failed to list documents: $e'));
    }
  }

  @override
  Future<Result<Uint8List, Exception>> downloadDocument(String uuid) async {
    try {
      // Find the document by UUID
      final document = _documents.firstWhere(
        (doc) => doc.uuid == uuid,
        orElse: () => throw Exception('Document not found'),
      );

      // Check if document is soft-deleted
      if (document.deletedAt != null) {
        return Error(Exception('Document has been deleted'));
      }

      // Read file from temporary directory (simulates Storage::Laravel facade)
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fake_docs/${document.uuid}');

      if (!await file.exists()) {
        return Error(Exception('Document file not found'));
      }

      final bytes = await file.readAsBytes();
      return Success(bytes);
    } catch (e) {
      return Error(Exception('Failed to download document: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocument(String uuid) async {
    try {
      // Find the document by UUID
      final document = _documents.firstWhere(
        (doc) => doc.uuid == uuid,
        orElse: () => throw Exception('Document not found'),
      );

      // Return document with all metadata (including deletedAt if present)
      return Success(document);
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
      // Find the document by UUID
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      final document = _documents[index];

      // Check if document is soft-deleted
      if (document.deletedAt != null) {
        return Error(Exception('Cannot update deleted document'));
      }

      // Update the document with new metadata (only update provided fields)
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
      return Error(Exception('Failed to update document: $e'));
    }
  }
}
