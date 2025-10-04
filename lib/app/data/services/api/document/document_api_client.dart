import 'package:multiple_result/multiple_result.dart';

abstract class DocumentUploadFile {
  String get path;
  String? get fileName;
  String get mimeType;
  int? get lengthInBytes;
}

abstract class DocumentUploadRequest {
  List<DocumentUploadFile> get files;
  String? get title;
  String? get patientName;
  String? get doctorName;
  String? get documentType;
  DateTime? get documentDate;
}

abstract class DocumentMetadataUpdateRequest {
  String? get title;
  String? get patientName;
  String? get doctorName;
  String? get documentType;
  DateTime? get documentDate;
}

abstract class DocumentSummaryApiModel {
  String get id;
  String get title;
  String? get patientName;
  String? get doctorName;
  String? get documentType;
  DateTime get createdAt;
  DateTime? get documentDate;
}

abstract class DocumentDetailApiModel extends DocumentSummaryApiModel {
  String? get filePath;
  DateTime? get deletedAt;
}

abstract class DocumentUploadResponseApiModel {
  String get documentId;
  DocumentDetailApiModel get document;
}

abstract class PaginationApiModel {
  int get currentPage;
  int get perPage;
  int get total;
  int get totalPages;
  bool get hasNext;
  bool get hasPrev;
}

abstract class DocumentPaginatedResponse {
  List<DocumentSummaryApiModel> get data;
  PaginationApiModel get pagination;
}

abstract class DocumentDeletionApiResponse {
  String get message;
  DateTime? get deletedAt;
}

abstract class DocumentDownloadApiResponse {
  String? get fileBase64;
  Uri? get downloadLink;
  String? get fileName;
}

abstract class DocumentApiClient {
  Future<Result<DocumentUploadResponseApiModel, Exception>> uploadDocuments(
    DocumentUploadRequest request,
  );

  Future<Result<DocumentPaginatedResponse, Exception>> listDocuments({
    int? page,
    int? perPage,
  });

  Future<Result<DocumentDetailApiModel, Exception>> getDocument(
    String documentId,
  );

  Future<Result<DocumentDetailApiModel, Exception>> updateDocument(
    String documentId,
    DocumentMetadataUpdateRequest request,
  );

  Future<Result<DocumentDeletionApiResponse, Exception>> deleteDocument(
    String documentId,
  );

  Future<Result<DocumentDownloadApiResponse, Exception>> downloadDocument(
    String documentId,
  );
}

class DocumentApiClientImpl implements DocumentApiClient {
  @override
  Future<Result<DocumentUploadResponseApiModel, Exception>> uploadDocuments(
    DocumentUploadRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentPaginatedResponse, Exception>> listDocuments({
    int? page,
    int? perPage,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentDetailApiModel, Exception>> getDocument(
    String documentId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentDetailApiModel, Exception>> updateDocument(
    String documentId,
    DocumentMetadataUpdateRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentDeletionApiResponse, Exception>> deleteDocument(
    String documentId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DocumentDownloadApiResponse, Exception>> downloadDocument(
    String documentId,
  ) {
    throw UnimplementedError();
  }
}
