import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:minha_saude_frontend/app/data/services/api/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/api/document/fake_document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/doc_scanner/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/file_system_service/file_system_service.dart';

class MockDocumentApiClient extends Mock implements FakeDocumentApiClient {}

class MockDocumentScanner extends Mock implements FakeDocumentScanner {}

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

  // uploadDocument uploads data through DocumentApiClient and stores cache in CacheDatabase
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
  });

  // listDocuments returns a list of documents provided by ApiClient, and caches the result on future calls
  // listDocuments does not cache results the second time if forceRefresh was true
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
    test("TEMPLATE", () {
      //
    });
  });

  // getDocumentMeta if called with non-existent document UUID on server returns Error
  // getDocumentMeta returns document metadata provided by ApiClient, and calls CacheDatabase to cache result
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
    test("TEMPLATE", () {
      //
    });
  });

  // getDocumentFile if called with non-existent document UUID on server returns Error
  // getDocumentFile returns document file provided by ApiClient, and calls FileSystemService to cache result
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
    test("TEMPLATE", () {
      //
    });
  });

  // updateDocument if called with non-existent document UUID on server returns Error
  // updateDocument if called with existent document UUID on server renews cache and returns Success with Document
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
    test("TEMPLATE", () {
      //
    });
  });

  // moveToTrash if called with non-existent document UUID on server returns Error
  // moveToTrash if called with existent document UUID on server fills deletedAt field on server and updates cache
  group("TEMPLATE", () {
    test("TEMPLATE", () {
      //
    });
    test("TEMPLATE", () {
      //
    });
  });
}
