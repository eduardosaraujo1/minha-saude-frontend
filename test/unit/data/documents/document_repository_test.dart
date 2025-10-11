import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/repositories/document/document_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/models/document_db_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import 'package:minha_saude_frontend/app/data/services/api/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/cache_database/document_cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/doc_scanner/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/file_system_service/file_system_service.dart';

class MockDocumentApiClient extends Mock implements DocumentApiClient {}

class MockDocumentScanner extends Mock implements DocumentScanner {}

class MockCacheDatabase extends Mock implements DocumentCacheDatabase {
  @override
  Future<void> init() async {}
}

class MockFileSystemService extends Mock implements FileSystemService {}

class MockFile extends Mock implements File {}

void main() {
  late DocumentApiClient documentApiClient;
  late DocumentScanner documentScanner;
  late DocumentCacheDatabase localDatabase;
  late FileSystemService fileSystemService;
  late DocumentRepositoryImpl documentRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(File("file.pdf"));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    documentApiClient = MockDocumentApiClient();
    documentScanner = MockDocumentScanner();
    localDatabase = MockCacheDatabase();
    fileSystemService = MockFileSystemService();
    documentRepository = DocumentRepositoryImpl(
      documentApiClient,
      localDatabase,
      documentScanner,
      fileSystemService,
    );
  });

  group("scanDocumentFile", () {
    test("calls scanPdf function", () {
      // Hook mockery to track scanPdf function calls but do nothing
      when(
        () => documentScanner.scanPdf(),
      ).thenAnswer((_) async => File("/doc/123.pdf"));

      // Call pickDocumentFile function
      documentScanner.scanPdf();

      // Assert scanPdf function was called
      verify(() => documentScanner.scanPdf()).called(1);
    });
  });

  group("pickDocumentFile ", () {
    test("calls pickPdfFile function", () {
      // Hook mockery to track pickPdfFile function calls but do nothing
      when(
        () => fileSystemService.pickPdfFile(),
      ).thenAnswer((_) async => File("/doc/456.pdf"));

      // Call pickDocumentFile function
      documentRepository.pickDocumentFile();

      // Assert pickPdfFile function was called
      verify(() => fileSystemService.pickPdfFile()).called(1);
    });
  });

  group("uploadDocument", () {
    test(
      "when uploadDocument is called with valid parameters then upload document to backend and store file and metadata locally",
      () async {
        // Setup
        final mockDocumentApiModel = DocumentApiModel(
          uuid: "test-uuid-123",
          titulo: "Test Document",
          nomePaciente: "John Doe",
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () => documentApiClient.uploadDocument(
            file: any(named: 'file'),
            titulo: any(named: 'titulo'),
            nomePaciente: any(named: 'nomePaciente'),
            nomeMedico: any(named: 'nomeMedico'),
            tipoDocumento: any(named: 'tipoDocumento'),
            dataDocumento: any(named: 'dataDocumento'),
          ),
        ).thenAnswer((_) async => Result.success(mockDocumentApiModel));

        when(
          () => localDatabase.upsertDocument(
            any(),
            titulo: any(named: 'titulo'),
            paciente: any(named: 'paciente'),
            medico: any(named: 'medico'),
            tipo: any(named: 'tipo'),
            dataDocumento: any(named: 'dataDocumento'),
            createdAt: any(named: 'createdAt'),
            deletedAt: any(named: 'deletedAt'),
            cachedAt: any(named: 'cachedAt'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            DocumentDbModel(
              uuid: "test-uuid-123",
              titulo: "Test Document",
              paciente: "John Doe",
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );

        final storedFile = File("/documents/test-uuid-123.pdf");
        final fileBytes = Uint8List.fromList([1, 2, 3]);
        final mockFile = MockFile();

        when(() => mockFile.readAsBytes()).thenAnswer((_) async => fileBytes);

        when(
          () => fileSystemService.storeDocument(any(), any()),
        ).thenAnswer((_) async => Result.success(storedFile));

        // Call uploadDocument function
        final result = await documentRepository.uploadDocument(
          mockFile,
          paciente: "John Doe",
          titulo: "Test Document",
          tipo: null,
          medico: null,
          dataDocumento: null,
        );

        expect(result.isSuccess(), true);

        // Assert DocumentApiClient uploadDocument, storeDocument and upsertDocument were called
        verify(
          () => documentApiClient.uploadDocument(
            file: mockFile,
            titulo: "Test Document",
            nomePaciente: "John Doe",
            nomeMedico: null,
            tipoDocumento: null,
            dataDocumento: null,
          ),
        ).called(1);

        verify(
          () => fileSystemService.storeDocument("test-uuid-123", fileBytes),
        ).called(1);

        verify(
          () => localDatabase.upsertDocument(
            "test-uuid-123",
            titulo: "Test Document",
            paciente: "John Doe",
            medico: null,
            tipo: null,
            dataDocumento: null,
            createdAt: DateTime(2025, 1, 1),
            deletedAt: null,
            cachedAt: any(named: 'cachedAt'),
          ),
        ).called(1);
      },
    );
  });

  group("listDocuments", () {
    test(
      "if ApiClient is available returns a list of documents provided by ApiClient and caches the result on subsequent calls",
      () async {
        // Hook DocumentApiClient listDocuments to return a list of documents with Mocktail
        final mockDocumentList = [
          DocumentApiModel(
            uuid: "uuid-1",
            titulo: "Doc 1",
            createdAt: DateTime(2025, 1, 1),
          ),
          DocumentApiModel(
            uuid: "uuid-2",
            titulo: "Doc 2",
            createdAt: DateTime(2025, 1, 2),
          ),
        ];

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => Result.success(mockDocumentList));

        when(
          () => localDatabase.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Call listDocuments function once
        final result1 = await documentRepository.listDocuments();

        // Assert return value is the same list of documents as provided by ApiClient
        expect(result1.isSuccess(), true);
        final documents1 = result1.tryGetSuccess()!;
        expect(documents1.length, 2);
        expect(documents1[0].uuid, "uuid-1");
        expect(documents1[1].uuid, "uuid-2");

        // Call listDocuments function again
        final result2 = await documentRepository.listDocuments();

        // Assert DocumentApiClient listDocuments was not called again and the value remains the same
        verify(() => documentApiClient.listDocuments()).called(1);
        verifyNever(
          () => localDatabase.upsertDocument(
            any(),
            titulo: any(named: 'titulo'),
            paciente: any(named: 'paciente'),
            medico: any(named: 'medico'),
            tipo: any(named: 'tipo'),
            dataDocumento: any(named: 'dataDocumento'),
            createdAt: any(named: 'createdAt'),
            deletedAt: any(named: 'deletedAt'),
          ),
        );
        verifyNever(() => localDatabase.listDocuments());
        expect(result2.isSuccess(), true);
        final documents2 = result2.tryGetSuccess()!;
        expect(documents2.length, 2);
        expect(documents2[0].uuid, "uuid-1");
        expect(documents2[1].uuid, "uuid-2");
      },
    );

    test(
      "when forceRefresh parameter is passed ApiClient should be called again",
      () async {
        // Hook DocumentApiClient listDocuments to return a list of documents with Mocktail
        final mockDocumentList = [
          DocumentApiModel(
            uuid: "uuid-1",
            titulo: "Doc 1",
            createdAt: DateTime(2025, 1, 1),
          ),
        ];

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => Result.success(mockDocumentList));

        when(
          () => localDatabase.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Call listDocuments function once
        final result1 = await documentRepository.listDocuments();

        // Assert function response is the same as provided to ApiClient
        expect(result1.isSuccess(), true);
        expect(result1.tryGetSuccess()!.length, 1);

        // Call listDocuments function once with forceRefresh = true
        final result2 = await documentRepository.listDocuments(
          forceRefresh: true,
        );

        // Assert DocumentApiClient listDocuments was called again and result remains the same
        verify(() => documentApiClient.listDocuments()).called(2);
        verifyNever(
          () => localDatabase.upsertDocument(
            any(),
            titulo: any(named: 'titulo'),
            paciente: any(named: 'paciente'),
            medico: any(named: 'medico'),
            tipo: any(named: 'tipo'),
            dataDocumento: any(named: 'dataDocumento'),
            createdAt: any(named: 'createdAt'),
            deletedAt: any(named: 'deletedAt'),
          ),
        );
        verifyNever(() => localDatabase.listDocuments());
        expect(result2.isSuccess(), true);
        expect(result2.tryGetSuccess()!.length, 1);
      },
    );
  });

  group("getDocumentMeta", () {
    test(
      "when called with non-existent document UUID on ApiClient then returns Error",
      () async {
        // Hook CacheDatabase getDocument with Mocktail to detect if it was called
        when(
          () => localDatabase.getDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        // Hook DocumentApiClient getDocumentMeta to return Error()
        final testError = Exception("Document not found");
        when(
          () => documentApiClient.getDocument(any()),
        ).thenAnswer((_) async => Result.error(testError));

        // Call repository getDocumentMeta
        final result = await documentRepository.getDocumentMeta(
          "non-existent-uuid",
        );

        // Assert method returned the same error as provided to ApiClient
        // Assert method returned Error
        expect(result.isError(), true);
        expect(result.tryGetError(), testError);
      },
    );
    test(
      "if document cache is unavailable when getDocumentMeta is called then it should call api, store cache result and return it",
      () async {
        // Hook CacheDatabase getDocument to return null (cache unavailable)
        when(
          () => localDatabase.getDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        // Hook DocumentApiClient getDocumentMeta to return Success with simple DocumentApiModel
        final mockDocumentApiModel = DocumentApiModel(
          uuid: "test-uuid",
          titulo: "Test Document",
          nomePaciente: "John Doe",
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () => documentApiClient.getDocument(any()),
        ).thenAnswer((_) async => Result.success(mockDocumentApiModel));

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Hook CacheDatabase upsertDocument with Mocktail to detect cache was stored
        when(
          () => localDatabase.upsertDocument(
            any(),
            titulo: any(named: 'titulo'),
            paciente: any(named: 'paciente'),
            medico: any(named: 'medico'),
            tipo: any(named: 'tipo'),
            dataDocumento: any(named: 'dataDocumento'),
            createdAt: any(named: 'createdAt'),
            deletedAt: any(named: 'deletedAt'),
            cachedAt: any(named: 'cachedAt'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            DocumentDbModel(
              uuid: "test-uuid",
              titulo: "Test Document",
              paciente: "John Doe",
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );

        // Call repository getDocumentMeta
        final result = await documentRepository.getDocumentMeta("test-uuid");

        // Assert response was same DocumentApiModel as provided in the hook
        expect(result.isSuccess(), true);
        final document = result.tryGetSuccess()!;
        expect(document.uuid, "test-uuid");
        expect(document.titulo, "Test Document");
        expect(document.paciente, "John Doe");

        // Assert upsertDocument was called once (cache was stored)
        verify(
          () => localDatabase.upsertDocument(
            "test-uuid",
            titulo: "Test Document",
            paciente: "John Doe",
            medico: null,
            tipo: null,
            dataDocumento: null,
            createdAt: DateTime(2025, 1, 1),
            deletedAt: null,
            cachedAt: any(named: 'cachedAt'),
          ),
        ).called(1);

        verify(() => documentApiClient.listDocuments()).called(1);
      },
    );

    test(
      "if document cache is available when getDocumentMeta is called then it should return the cache without calling ApiClient",
      () async {
        // Hook CacheDatabase getDocument to return a simple DocumentDbModel (cache available)
        final mockDocumentDbModel = DocumentDbModel(
          uuid: "test-uuid",
          titulo: "Cached Document",
          paciente: "Jane Doe",
          createdAt: DateTime(2025, 1, 1),
          cachedAt: DateTime.now(),
        );

        when(
          () => localDatabase.getDocument(any()),
        ).thenAnswer((_) async => Result.success(mockDocumentDbModel));

        // Hook DocumentApiClient getDocumentMeta with Mocktail to detect if it was called
        when(() => documentApiClient.getDocument(any())).thenAnswer(
          (_) async => Result.success(
            DocumentApiModel(
              uuid: "test-uuid",
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Call repository getDocumentMeta
        final result = await documentRepository.getDocumentMeta("test-uuid");

        // Assert response was the same DocumentDbModel as provided in the hook
        expect(result.isSuccess(), true);
        final document = result.tryGetSuccess()!;
        expect(document.uuid, "test-uuid");
        expect(document.titulo, "Cached Document");
        expect(document.paciente, "Jane Doe");

        // Assert DocumentApiClient getDocumentMeta was never called (cache was used)
        verifyNever(() => documentApiClient.getDocument(any()));
        verifyNever(() => documentApiClient.listDocuments());

        // Assert CacheDatabase getDocument was called once (cache was used)
        verify(() => localDatabase.getDocument("test-uuid")).called(1);
      },
    );
  });
  group("getDocumentFile", () {
    test(
      "if called with non-existent document UUID on server then returns Error",
      () async {
        // Hook FileSystemService getDocument to return Success(null) (no cache)
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        // Hook ApiClient downloadDocument to return Error
        final testError = Exception("Document not found on server");
        when(
          () => documentApiClient.downloadDocument(any()),
        ).thenAnswer((_) async => Result.error(testError));

        // Call getDocumentFile
        final result = await documentRepository.getDocumentFile(
          "non-existent-uuid",
        );

        // Assert method returned the same Error as provided to ApiClient
        expect(result.isError(), true);
        expect(result.tryGetError(), testError);
      },
    );
    test(
      "if cache is unavailable when getDocumentFile is called then it should download from ApiClient, store in cache and return the file",
      () async {
        // Hook ApiClient downloadDocument to return Success with simple Uint8List
        final mockBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          () => documentApiClient.downloadDocument(any()),
        ).thenAnswer((_) async => Result.success(mockBytes));

        // Hook FileSystemService getDocument to return Success(null), indicating no cache
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        // Hook FileSystemService storeDocument to detect if it was run
        final storedFile = MockFile();
        when(
          () => fileSystemService.storeDocument(any(), any()),
        ).thenAnswer((_) async => Result.success(storedFile));

        // Call getDocumentFile
        final result = await documentRepository.getDocumentFile("test-uuid");

        // Assert method returned Success with File
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), same(storedFile));

        // Assert ApiClient.downloadDocument was called once
        verify(() => documentApiClient.downloadDocument("test-uuid")).called(1);

        // Assert FileSystemService.storeDocument was called once with correct parameters
        verify(
          () => fileSystemService.storeDocument("test-uuid", mockBytes),
        ).called(1);
      },
    );

    test(
      "if cache is available when getDocumentFile is called then it should return the file from cache without calling ApiClient",
      () async {
        // Hook ApiClient downloadDocument to assert it was never run
        when(() => documentApiClient.downloadDocument(any())).thenAnswer(
          (_) async => Result.success(Uint8List.fromList([1, 2, 3])),
        );

        // Hook FileSystemService getDocument() to return Success(File(path))
        final mockFile = File("/cache/test-uuid.pdf");
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => Result.success(mockFile));

        // Call getDocumentFile
        final result = await documentRepository.getDocumentFile("test-uuid");

        // Assert method returned Success with the same file as provided in the hook
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), mockFile);

        // Assert ApiClient.downloadDocument was never called
        verifyNever(() => documentApiClient.downloadDocument(any()));
      },
    );
  });

  group("updateDocument", () {
    test(
      "when called with non-existent document UUID then it should return Error",
      () async {
        // Hook ApiClient updateDocument to return Error
        final testError = Exception("Document not found");
        when(
          () => documentApiClient.updateDocument(
            any(),
            titulo: any(named: 'titulo'),
            nomePaciente: any(named: 'nomePaciente'),
            nomeMedico: any(named: 'nomeMedico'),
            tipoDocumento: any(named: 'tipoDocumento'),
            dataDocumento: any(named: 'dataDocumento'),
          ),
        ).thenAnswer((_) async => Result.error(testError));

        // Call updateDocument
        final result = await documentRepository.updateDocument(
          "non-existent-uuid",
          titulo: "Updated Title",
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(result.tryGetError(), testError);
      },
    );
    test(
      "when called with existent document UUID on server then it should renew cache and returns Success with Document model",
      () async {
        // Hook ApiClient updateDocument to return Success
        final mockUpdatedDocument = DocumentApiModel(
          uuid: "test-uuid",
          titulo: "Updated Title",
          nomePaciente: "John Doe",
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () => documentApiClient.updateDocument(
            any(),
            titulo: any(named: 'titulo'),
            nomePaciente: any(named: 'nomePaciente'),
            nomeMedico: any(named: 'nomeMedico'),
            tipoDocumento: any(named: 'tipoDocumento'),
            dataDocumento: any(named: 'dataDocumento'),
          ),
        ).thenAnswer((_) async => Result.success(mockUpdatedDocument));

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Hook CacheDatabase upsertDocument to detect cache update
        when(
          () => localDatabase.upsertDocument(
            any(),
            titulo: any(named: 'titulo'),
            paciente: any(named: 'paciente'),
            medico: any(named: 'medico'),
            tipo: any(named: 'tipo'),
            dataDocumento: any(named: 'dataDocumento'),
            createdAt: any(named: 'createdAt'),
            deletedAt: any(named: 'deletedAt'),
            cachedAt: any(named: 'cachedAt'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            DocumentDbModel(
              uuid: "test-uuid",
              titulo: "Updated Title",
              paciente: "John Doe",
              createdAt: DateTime(2025, 1, 1),
            ),
          ),
        );

        // Call updateDocument
        final result = await documentRepository.updateDocument(
          "test-uuid",
          titulo: "Updated Title",
          paciente: "John Doe",
        );

        // Assert method returned Success with updated Document
        expect(result.isSuccess(), true);
        final document = result.tryGetSuccess()!;
        expect(document.uuid, "test-uuid");
        expect(document.titulo, "Updated Title");

        // Assert cache was updated
        verify(
          () => localDatabase.upsertDocument(
            "test-uuid",
            titulo: "Updated Title",
            paciente: "John Doe",
            medico: null,
            tipo: null,
            dataDocumento: null,
            createdAt: DateTime(2025, 1, 1),
            deletedAt: null,
            cachedAt: any(named: 'cachedAt'),
          ),
        ).called(1);
      },
    );
  });

  group("moveToTrash", () {
    test(
      "when called with non-existent document UUID on server then it should return Error",
      () async {
        // Hook ApiClient trashDocument to return Error
        final testError = Exception("Document not found");
        when(
          () => documentApiClient.trashDocument(any()),
        ).thenAnswer((_) async => Result.error(testError));

        // Call moveToTrash
        final result = await documentRepository.moveToTrash(
          "non-existent-uuid",
        );

        // Assert method returned Error
        expect(result.isError(), true);
        expect(result.tryGetError(), testError);
      },
    );
    test(
      "when called with existent document UUID on server then it should call trashDocument on server and call trashDocument on CacheDatabase",
      () async {
        // Hook ApiClient trashDocument to return Success
        when(
          () => documentApiClient.trashDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => const Result.success([]));

        // Hook CacheDatabase trashDocument to detect it was called
        when(
          () => localDatabase.trashDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        // Call moveToTrash
        final result = await documentRepository.moveToTrash("test-uuid");

        // Assert method returned Success
        expect(result.isSuccess(), true);

        // Assert ApiClient trashDocument was called
        verify(() => documentApiClient.trashDocument("test-uuid")).called(1);

        // Assert CacheDatabase trashDocument was called
        verify(() => localDatabase.trashDocument("test-uuid")).called(1);
      },
    );
  });
}
