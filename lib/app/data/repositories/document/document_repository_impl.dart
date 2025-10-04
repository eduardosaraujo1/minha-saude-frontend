import 'dart:io';

import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';
import 'document_repository.dart';

class DocumentRepositoryImpl extends DocumentRepository {
  DocumentRepositoryImpl();

  @override
  Future<Result<Document, Exception>> editDocument(
    String id, {
    String? titulo,
    String? paciente,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
  }) {
    // TODO: implement editDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> getDocument(String id) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  }) {
    // TODO: implement listDocuments
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> moveToTrash(String id) {
    // TODO: implement moveToTrash
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> pickDocumentFile() {
    // TODO: implement pickDocumentFile
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> scanDocumentFile() {
    // TODO: implement scanDocumentFile
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> uploadDocument(
    File file, {
    required String paciente,
    required String titulo,
    required String tipo,
    required String medico,
    required DateTime dataDocumento,
  }) {
    // TODO: implement uploadDocument
    throw UnimplementedError();
  }
}
