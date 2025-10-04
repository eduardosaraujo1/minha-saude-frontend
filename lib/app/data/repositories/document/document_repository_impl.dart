import 'dart:io';

import 'package:multiple_result/multiple_result.dart';

import '../../../domain/models/document/document.dart';
import 'document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  @override
  Future<void> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> deleteDocument(String documentId) {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> downloadDocument(String documentId) {
    // TODO: implement downloadDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> getDocumentById(
    String documentId, {
    bool forceRefresh = false,
  }) {
    // TODO: implement getDocumentById
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Document>, Exception>> listDeletedDocuments({
    bool forceRefresh = false,
  }) {
    // TODO: implement listDeletedDocuments
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
  Stream<List<Document>> observeDeletedDocuments() {
    // TODO: implement observeDeletedDocuments
    throw UnimplementedError();
  }

  @override
  Stream<List<Document>> observeDocuments() {
    // TODO: implement observeDocuments
    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> updateDocument(Document documentModel) {
    // TODO: implement updateDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<Document, Exception>> uploadDocument(
    DocumentUploadPayload payload,
  ) {
    // TODO: implement uploadDocument
    throw UnimplementedError();
  }
}
