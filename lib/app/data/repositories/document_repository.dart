import 'package:minha_saude_frontend/app/domain/models/document.dart';
import 'package:multiple_result/multiple_result.dart';

class DocumentDownloadResource {
  const DocumentDownloadResource({
    this.fileBytes,
    this.fileName,
    this.downloadUri,
  }) : assert(
         fileBytes != null || downloadUri != null,
         'Either fileBytes or downloadUri must be provided.',
       );

  final List<int>? fileBytes;
  final String? fileName;
  final Uri? downloadUri;
}

class DocumentUploadPayload {
  const DocumentUploadPayload({
    required this.files,
    this.title,
    this.patientName,
    this.doctorName,
    this.documentType,
    this.documentDate,
  });

  final List<UploadableDocumentFile> files;
  final String? title;
  final String? patientName;
  final String? doctorName;
  final String? documentType;
  final DateTime? documentDate;
}

class UploadableDocumentFile {
  const UploadableDocumentFile({
    required this.path,
    required this.mimeType,
    this.fileName,
    this.lengthInBytes,
  });

  final String path;
  final String mimeType;
  final String? fileName;
  final int? lengthInBytes;
}

class DocumentMetadataUpdatePayload {
  const DocumentMetadataUpdatePayload({
    this.title,
    this.patientName,
    this.doctorName,
    this.documentType,
    this.documentDate,
  });

  final String? title;
  final String? patientName;
  final String? doctorName;
  final String? documentType;
  final DateTime? documentDate;
}

abstract class DocumentRepository {
  /// Returns current cached documents and optionally refreshes from the API when [forceRefresh] is true.
  Future<Result<List<Document>, Exception>> listDocuments({
    bool forceRefresh = false,
  });

  /// Reactive stream that emits whenever the cached document collection changes.
  Stream<List<Document>> observeDocuments();

  /// Returns deleted documents kept in local cache.
  Future<Result<List<Document>, Exception>> listDeletedDocuments({
    bool forceRefresh = false,
  });

  /// Reactive stream for deleted documents that updates as cache changes.
  Stream<List<Document>> observeDeletedDocuments();

  /// Fetches a single document either from cache or remote when [forceRefresh] is true.
  Future<Result<Document, Exception>> getDocumentById(
    String documentId, {
    bool forceRefresh = false,
  });

  /// Uploads a new document to the remote API and merges the response into the cache.
  Future<Result<Document, Exception>> uploadDocument(
    DocumentUploadPayload payload,
  );

  /// Updates metadata for an existing document.
  Future<Result<Document, Exception>> updateDocumentMetadata(
    String documentId,
    DocumentMetadataUpdatePayload payload,
  );

  /// Soft deletes a document and updates local cache state accordingly.
  Future<Result<void, Exception>> deleteDocument(String documentId);

  /// Retrieves a downloadable artifact for the given document id.
  Future<Result<DocumentDownloadResource, Exception>> downloadDocument(
    String documentId,
  );

  /// Hydrates caches from remote API on app start or explicit refresh requests.
  Future<Result<void, Exception>> warmUp();

  /// Clears local caches, used when user signs out or switches account.
  Future<void> clearCache();
}
