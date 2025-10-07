import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import 'package:minha_saude_frontend/app/data/services/api/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/doc_scanner/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/file_system_service/file_system_service.dart';

class MockDocumentApiClient extends Mock implements DocumentApiClient {}

class MockDocumentScanner extends Mock implements DocumentScanner {}

class MockCacheDatabase extends Mock implements CacheDatabase {
  @override
  Future<void> init() async {}
}

class MockFileSystemService extends Mock implements FileSystemService {}

void main() {
  late DocumentApiClient _documentApiClient;
  late DocumentScanner _documentScanner;
  late CacheDatabase _localDatabase;
  late FileSystemService _filePickerService;

  setUp(() {
    _documentApiClient = MockDocumentApiClient();
    _documentScanner = MockDocumentScanner();
    _localDatabase = MockCacheDatabase();
    _filePickerService = MockFileSystemService();
  });

  group("scanDocumentFile", () {
    test("calls scanPdf function", () {
      // Hook mockery to track scanPdf function calls but do nothing

      // Call pickDocumentFile function

      // Assert scanPdf function was called
    });
  });

  //
  group("pickDocumentFile ", () {
    test("calls pickPdfFile function", () {
      // Hook mockery to track pickPdfFile function calls but do nothing

      // Call pickDocumentFile function

      // Assert scanPdf function was called
    });
  });

  group("uploadDocument", () {
    test(
      "when uploadDocument is called with valid parameters then upload document to backend and store file and metadata locally",
      () {
        // Hook MockCacheDatabase upsertDocument with Mocktail
        // Hook MockFileSystemService storeDocumentFile with Mocktail
        // Hook DocumentApiClient uploadDocument with Mocktail

        // Call uploadDocument function

        // Assert DocumentApiClient uploadDocument, storeDocumentFile and upsertDocument was called
      },
    );
  });

  group("listDocuments", () {
    test(
      "if ApiClient is available returns a list of documents provided by ApiClient and caches the result on subsequent calls",
      () {
        // Hook DocumentApiClient listDocuments to return a list of documents with Mocktail

        // Call listDocuments function once

        // Assert return value is the same list of documents as provided by ApiClient

        // Call listDocuments function again

        // Assert DocumentApiClient listDocuments was not called again and the value remains the same
      },
    );

    test(
      "when forceRefresh parameter is passed ApiClient should be called again",
      () {
        // Hook DocumentApiClient listDocuments to return a list of documents with Mocktail

        // Call listDocuments function once

        // Assert function response is the same as provided to ApiClient

        // Call listDocuments function once with forceRefresh = true

        // Assert DocumentApiClient listDocuments was called again and result remains the same
      },
    );
  });

  group("getDocumentMeta", () {
    test(
      "when called with non-existent document UUID on ApiClient then returns Error",
      () {
        // Hook CacheDatabase getDocument with Mocktail to avoid exceptions (by default the method checks for a cache hit)
        // Hook DocumentApiClient getDocumentMeta to return Error()

        // Call repository getDocumentMeta

        // Assert method returned Error
      },
    );
    test(
      "if document with provided UUID exists when getDocumentMeta is called then it should cache result and return it",
      () {
        // Hook DocumentApiClient getDocumentMeta to return success with DocumentApiModel
        // Hook CacheDatabase upsertDocument with Mocktail to detect if it was called

        // Call repository getDocumentMeta

        // Assert response was same DocumentApiModel as provided in the hook
        // Assert upsertDocument was called once (cache was stored)

        // Hook CacheDatabase getDocument to return the same DocumentApiModel

        // Call repository getDocumentMeta again

        // Assert response was the same ApiModel
        // Assert DocumentApiClient getDocumentMeta was not called again (cache was used)
        // Assert CacheDatabase getDocument was called once (cache was used)
      },
    );
  });
  group("getDocumentFile", () {
    test(
      "if called with non-existent document UUID on server then returns Error",
      () {
        // Hook FileSystemService getDocumentFile to return Success(null) (no cache)
        // Hook ApiClient downloadDocument to return Error

        // Call getDocumentFile

        // Assert method returned the same Error as provided to ApiClient
      },
    );
    test(
      "when run first time get document from server and store cache; when cache is available read from it",
      () {
        // Hook ApiClient downloadDocument to detect if it was run
        // Hook FileSystemService storeDocumentBytes to detect if it was run
        // Hook FileSystemService getDocumentFile to return null if storeDocumentBytes was not run yet (if not possible change the Mock implementation)

        // Call getDocumentFile

        // Assert ApiClient.downloadDocument was called once
        // Assert FileSystemService.storeDocument was called once
        // Assert FileSystemService.storeDocument was called once
      },
    );
  });

  group("updateDocument", () {
    test(
      "if called with non-existent document UUID on server returns Error",
      () {
        //
      },
    );
    test(
      "if called with existent document UUID on server renews cache and returns Success with Document",
      () {
        //
      },
    );
  });

  group("moveToTrash", () {
    test(
      "if called with non-existent document UUID on server returns Error",
      () {
        //
      },
    );
    test(
      "if called with existent document UUID on server fills deletedAt field on server and updates cache",
      () {
        //
      },
    );
  });
}
