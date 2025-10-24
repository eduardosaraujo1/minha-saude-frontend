import 'dart:io';
import 'dart:typed_data';

import 'package:multiple_result/multiple_result.dart';
import 'package:uuid/uuid.dart';

import '../../fakes/fake_server_database.dart';
import '../../fakes/fake_server_file_storage.dart';
import 'document_api_client.dart';
import 'models/document_api_model/document_api_model.dart';

/// Fake implementation of DocumentApiClient for testing/development
/// Simulates backend API behavior using FakeServerDatabase and FakeServerFileStorage
class FakeDocumentApiClient implements DocumentApiClient {
  FakeDocumentApiClient({
    required this.fakeServerDatabase,
    required this.fakeServerFileStorage,
  });

  // Server-side storage (simulates backend)
  final FakeServerDatabase fakeServerDatabase;
  final FakeServerFileStorage fakeServerFileStorage;

  // UUID generator (simulates server-side UUID generation)
  final _uuid = const Uuid();

  // Helper to get the current user (in fake, we just use the first user)
  Future<int?> _getCurrentUserId() async {
    final users = await fakeServerDatabase.users.readAll();
    if (users.isEmpty) return null;
    return users.first['id'] as int;
  }

  @override
  Future<Result<void, Exception>> trashDocument(String uuid) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Soft delete the document
      await fakeServerDatabase.documents.updateByUuid(uuid, {
        'deleted_at': DateTime.now().toIso8601String(),
      });

      return Success(null);
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

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Error(Exception('No user found'));
      }

      // Generate new UUID (simulates server-side generation)
      final uuid = _uuid.v4();

      // Store file in server storage
      final fileResult = await fakeServerFileStorage.put(uuid, file);
      if (fileResult.isError()) {
        return Error(fileResult.tryGetError()!);
      }

      // Create document in database
      await fakeServerDatabase.documents.create({
        'uuid': uuid,
        'titulo': titulo ?? 'Documento sem título',
        'nome_paciente': nomePaciente,
        'nome_medico': nomeMedico,
        'tipo_documento': tipoDocumento,
        'data_documento': dataDocumento?.toIso8601String().split('T')[0],
        'usuario_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

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

      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Success([]);
      }

      // Query all non-deleted documents for this user
      final documents = await fakeServerDatabase.documents.findByUser(userId);

      // Convert to DocumentApiModel
      final documentModels = documents.map((doc) {
        return DocumentApiModel(
          uuid: doc['uuid'] as String,
          titulo: doc['titulo'] as String,
          nomePaciente: doc['nome_paciente'] as String?,
          nomeMedico: doc['nome_medico'] as String?,
          tipoDocumento: doc['tipo_documento'] as String?,
          dataDocumento: doc['data_documento'] != null
              ? DateTime.parse(doc['data_documento'] as String)
              : null,
          createdAt: DateTime.parse(doc['created_at'] as String),
        );
      }).toList();

      return Success(documentModels);
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
      final docData = await fakeServerDatabase.documents.findByUuid(uuid);
      if (docData == null) {
        return Error(Exception('Document not found'));
      }

      if (docData['deleted_at'] != null) {
        return Error(Exception('Document has been deleted'));
      }

      // Query file from server storage
      final fileResult = await fakeServerFileStorage.get(uuid);
      if (fileResult.isError()) {
        return Error(fileResult.tryGetError()!);
      }

      // Read file bytes
      final file = fileResult.tryGetSuccess()!;
      final bytes = await file.readAsBytes();
      return Success(bytes);
    } catch (e) {
      return Error(Exception('Failed to download document: $e'));
    }
  }

  @override
  Future<Result<DocumentApiModel, Exception>> getDocument(String uuid) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 400));

      // Query document metadata from database
      final docData = await fakeServerDatabase.documents.findByUuid(uuid);
      if (docData == null) {
        return Error(Exception('Document not found'));
      }

      return Success(
        DocumentApiModel(
          uuid: docData['uuid'] as String,
          titulo: docData['titulo'] as String,
          nomePaciente: docData['nome_paciente'] as String?,
          nomeMedico: docData['nome_medico'] as String?,
          tipoDocumento: docData['tipo_documento'] as String?,
          dataDocumento: docData['data_documento'] != null
              ? DateTime.parse(docData['data_documento'] as String)
              : null,
          createdAt: DateTime.parse(docData['created_at'] as String),
        ),
      );
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

      // Build update data
      final updateData = <String, dynamic>{};
      if (titulo != null) updateData['titulo'] = titulo;
      if (nomePaciente != null) updateData['nome_paciente'] = nomePaciente;
      if (nomeMedico != null) updateData['nome_medico'] = nomeMedico;
      if (tipoDocumento != null) updateData['tipo_documento'] = tipoDocumento;
      if (dataDocumento != null) {
        updateData['data_documento'] = dataDocumento.toIso8601String().split(
          'T',
        )[0];
      }

      // Update in database
      await fakeServerDatabase.documents.updateByUuid(uuid, updateData);

      // Get updated document
      final docData = await fakeServerDatabase.documents.findByUuid(uuid);
      if (docData == null) {
        return Error(Exception('Document not found after update'));
      }

      return Success(
        DocumentApiModel(
          uuid: docData['uuid'] as String,
          titulo: docData['titulo'] as String,
          nomePaciente: docData['nome_paciente'] as String?,
          nomeMedico: docData['nome_medico'] as String?,
          tipoDocumento: docData['tipo_documento'] as String?,
          dataDocumento: docData['data_documento'] != null
              ? DateTime.parse(docData['data_documento'] as String)
              : null,
          createdAt: DateTime.parse(docData['created_at'] as String),
        ),
      );
    } catch (e) {
      return Error(Exception('Failed to update document: $e'));
    }
  }
}
