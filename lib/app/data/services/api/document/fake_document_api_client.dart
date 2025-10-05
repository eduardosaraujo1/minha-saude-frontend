import 'dart:io';
import 'dart:typed_data';

import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'models/document_api_model.dart';
import 'document_api_client.dart';

class FakeDocumentApiClient implements DocumentApiClient {
  // In-memory storage for document metadata
  final List<DocumentApiModel> _documents = [];

  // Counter for generating incrementing IDs
  int _nextId = 1;

  // UUID generator
  final _uuid = const Uuid();

  @override
  Future<Result<void, Exception>> deleteDocument(String documentId) async {
    try {
      // Find the document by ID
      final index = _documents.indexWhere(
        (doc) => doc.idDocumento == documentId,
      );

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
  Future<Result<void, Exception>> documentUpload({
    required File file,
    String? filename,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    try {
      // Generate new document ID and UUID
      final documentId = _nextId.toString();
      _nextId++;
      final uuid = _uuid.v4();

      // Copy file to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fakeDocsDir = Directory('${tempDir.path}/fake_docs');
      if (!await fakeDocsDir.exists()) {
        await fakeDocsDir.create(recursive: true);
      }

      final destinationPath = '${fakeDocsDir.path}/$uuid';
      await file.copy(destinationPath);

      // Create document metadata
      final document = DocumentApiModel(
        idDocumento: documentId,
        uuid: uuid,
        titulo: titulo ?? filename ?? 'Untitled Document',
        nomePaciente: nomePaciente,
        nomeMedico: nomeMedico,
        tipoDocumento: tipoDocumento,
        dataDocumento: dataDocumento,
        createdAt: DateTime.now(),
      );

      _documents.add(document);

      return const Success(null);
    } catch (e) {
      return Error(Exception('Failed to upload document: $e'));
    }
  }

  @override
  Future<Result<List<DocumentApiModel>, Exception>> documentsList() async {
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
  Future<Result<Uint8List, Exception>> downloadDocument(
    String documentId,
  ) async {
    try {
      // Find the document by ID
      final document = _documents.firstWhere(
        (doc) => doc.idDocumento == documentId,
        orElse: () => throw Exception('Document not found'),
      );

      // Read file from temporary directory
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
  Future<Result<DocumentApiModel, Exception>> getDocumentMeta(
    String documentId,
  ) async {
    try {
      // Find the document by ID
      final document = _documents.firstWhere(
        (doc) => doc.idDocumento == documentId,
        orElse: () => throw Exception('Document not found'),
      );

      return Success(document);
    } catch (e) {
      return Error(Exception('Failed to get document metadata: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> updateDocument(
    String documentId, {
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
  }) async {
    try {
      // Find the document by ID
      final index = _documents.indexWhere(
        (doc) => doc.idDocumento == documentId,
      );

      if (index == -1) {
        return Error(Exception('Document not found'));
      }

      // Update the document with new metadata
      final document = _documents[index];
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
