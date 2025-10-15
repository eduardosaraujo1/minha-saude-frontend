import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/repositories/document/document_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/models/document_db_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import 'package:minha_saude_frontend/app/data/services/api/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/doc_scanner/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/local/file_system_service/file_system_service.dart';

class MockDocumentApiClient extends Mock implements DocumentApiClient {}

class MockDocumentScanner extends Mock implements DocumentScanner {}

class MockCacheDatabase extends Mock implements CacheDatabase {
  @override
  Future<void> init() async {}
}

class MockFileSystemService extends Mock implements FileSystemService {}

class MockFile extends Mock implements File {}

void main() {
  late DocumentApiClient documentApiClient;
  late DocumentScanner documentScanner;
  late CacheDatabase localDatabase;
  late FileSystemService fileSystemService;
  late DocumentRepositoryImpl documentRepository;

  setUpAll(() {
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

  // Helper function to setup successful document upload mocks
  void setupSuccessfulUploadMocks({
    required DocumentApiModel apiModel,
    required MockFile mockFile,
    required Uint8List fileBytes,
    required File storedFile,
  }) {
    when(
      () => documentApiClient.uploadDocument(
        file: any(named: 'file'),
        titulo: any(named: 'titulo'),
        nomePaciente: any(named: 'nomePaciente'),
        nomeMedico: any(named: 'nomeMedico'),
        tipoDocumento: any(named: 'tipoDocumento'),
        dataDocumento: any(named: 'dataDocumento'),
      ),
    ).thenAnswer((_) async => Result.success(apiModel));

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
          uuid: apiModel.uuid,
          titulo: apiModel.titulo,
          paciente: apiModel.nomePaciente,
          createdAt: apiModel.createdAt,
        ),
      ),
    );

    when(() => mockFile.readAsBytes()).thenAnswer((_) async => fileBytes);

    when(
      () => fileSystemService.storeDocument(any(), any()),
    ).thenAnswer((_) async => Result.success(storedFile));
  }

  group("Document Scanner and Picker", () {
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

  group("Document Upload", () {
    late DocumentApiModel mockDocumentApiModel;
    late MockFile mockFile;
    late Uint8List fileBytes;
    late File storedFile;

    setUp(() {
      mockDocumentApiModel = DocumentApiModel(
        uuid: "test-uuid-123",
        titulo: "Test Document",
        nomePaciente: "John Doe",
        createdAt: DateTime(2025, 1, 1),
      );

      mockFile = MockFile();
      fileBytes = Uint8List.fromList([1, 2, 3]);
      storedFile = File("/documents/test-uuid-123.pdf");
    });

    test("uploads document to API client with correct parameters", () async {
      setupSuccessfulUploadMocks(
        apiModel: mockDocumentApiModel,
        mockFile: mockFile,
        fileBytes: fileBytes,
        storedFile: storedFile,
      );

      final result = await documentRepository.uploadDocument(
        mockFile,
        paciente: "John Doe",
        titulo: "Test Document",
        tipo: null,
        medico: null,
        dataDocumento: null,
      );

      expect(result.isSuccess(), true);
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
    });

    test("stores file locally with correct UUID and bytes", () async {
      setupSuccessfulUploadMocks(
        apiModel: mockDocumentApiModel,
        mockFile: mockFile,
        fileBytes: fileBytes,
        storedFile: storedFile,
      );

      final result = await documentRepository.uploadDocument(
        mockFile,
        paciente: "John Doe",
        titulo: "Test Document",
        tipo: null,
        medico: null,
        dataDocumento: null,
      );

      expect(result.isSuccess(), true);
      verify(
        () => fileSystemService.storeDocument("test-uuid-123", fileBytes),
      ).called(1);
    });

    test("caches document metadata in database", () async {
      setupSuccessfulUploadMocks(
        apiModel: mockDocumentApiModel,
        mockFile: mockFile,
        fileBytes: fileBytes,
        storedFile: storedFile,
      );

      final result = await documentRepository.uploadDocument(
        mockFile,
        paciente: "John Doe",
        titulo: "Test Document",
        tipo: null,
        medico: null,
        dataDocumento: null,
      );

      expect(result.isSuccess(), true);
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
    });
  });

  group("Index Documents", () {
    late List<DocumentApiModel> mockDocumentList;

    setUp(() {
      mockDocumentList = [
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
        () => localDatabase.listDocuments(),
      ).thenAnswer((_) async => const Result.success([]));
    });

    test("returns documents from ApiClient when available", () async {
      when(
        () => documentApiClient.listDocuments(),
      ).thenAnswer((_) async => Result.success(mockDocumentList));

      final result = await documentRepository.listDocuments();

      expect(result.isSuccess(), true);
      final documents = result.tryGetSuccess()!;
      expect(documents.length, 2);
      expect(documents[0].uuid, "uuid-1");
      expect(documents[1].uuid, "uuid-2");
    });

    test(
      "caches results and doesn't call API again on subsequent calls",
      () async {
        when(
          () => documentApiClient.listDocuments(),
        ).thenAnswer((_) async => Result.success(mockDocumentList));

        await documentRepository.listDocuments();
        final result2 = await documentRepository.listDocuments();

        verify(() => documentApiClient.listDocuments()).called(1);
        verifyNever(() => localDatabase.listDocuments());
        expect(result2.isSuccess(), true);
        expect(result2.tryGetSuccess()!.length, 2);
      },
    );

    test("calls ApiClient again when forceRefresh is true", () async {
      when(
        () => documentApiClient.listDocuments(),
      ).thenAnswer((_) async => Result.success(mockDocumentList));

      await documentRepository.listDocuments();
      final result2 = await documentRepository.listDocuments(
        forceRefresh: true,
      );

      verify(() => documentApiClient.listDocuments()).called(2);
      expect(result2.isSuccess(), true);
      expect(result2.tryGetSuccess()!.length, 2);
    });
  });

  group("getDocumentMeta", () {
    setUp(() {
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
    });

    test("returns Error when document doesn't exist on ApiClient", () async {
      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final testError = Exception("Document not found");
      when(
        () => documentApiClient.getDocument(any()),
      ).thenAnswer((_) async => Result.error(testError));

      final result = await documentRepository.getDocumentMeta(
        "non-existent-uuid",
      );

      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });

    test("fetches from API and caches when cache is unavailable", () async {
      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => const Result.success(null));

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

      final result = await documentRepository.getDocumentMeta("test-uuid");

      expect(result.isSuccess(), true);
      final document = result.tryGetSuccess()!;
      expect(document.uuid, "test-uuid");
      expect(document.titulo, "Test Document");
      expect(document.paciente, "John Doe");

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
    });

    test(
      "returns cached document without calling API when cache is available",
      () async {
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

        final result = await documentRepository.getDocumentMeta("test-uuid");

        expect(result.isSuccess(), true);
        final document = result.tryGetSuccess()!;
        expect(document.uuid, "test-uuid");
        expect(document.titulo, "Cached Document");
        expect(document.paciente, "Jane Doe");

        verifyNever(() => documentApiClient.getDocument(any()));
        verifyNever(() => documentApiClient.listDocuments());
        verify(() => localDatabase.getDocument("test-uuid")).called(1);
      },
    );
  });
  group("getDocumentFile", () {
    test("returns Error when document doesn't exist on server", () async {
      when(
        () => fileSystemService.getDocument(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final testError = Exception("Document not found on server");
      when(
        () => documentApiClient.downloadDocument(any()),
      ).thenAnswer((_) async => Result.error(testError));

      final result = await documentRepository.getDocumentFile(
        "non-existent-uuid",
      );

      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });

    test(
      "downloads from API and stores locally when cache is unavailable",
      () async {
        final mockBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          () => documentApiClient.downloadDocument(any()),
        ).thenAnswer((_) async => Result.success(mockBytes));

        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => const Result.success(null));

        final storedFile = MockFile();
        when(
          () => fileSystemService.storeDocument(any(), any()),
        ).thenAnswer((_) async => Result.success(storedFile));

        final result = await documentRepository.getDocumentFile("test-uuid");

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), same(storedFile));

        verify(() => documentApiClient.downloadDocument("test-uuid")).called(1);
        verify(
          () => fileSystemService.storeDocument("test-uuid", mockBytes),
        ).called(1);
      },
    );

    test(
      "returns cached file without calling API when cache is available",
      () async {
        final mockFile = File("/cache/test-uuid.pdf");
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => Result.success(mockFile));

        final result = await documentRepository.getDocumentFile("test-uuid");

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), mockFile);

        verifyNever(() => documentApiClient.downloadDocument(any()));
      },
    );
  });

  group("updateDocument", () {
    setUp(() {
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
    });

    test("returns Error when document doesn't exist", () async {
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

      final result = await documentRepository.updateDocument(
        "non-existent-uuid",
        titulo: "Updated Title",
      );

      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });

    test("updates document on server and renews cache", () async {
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

      final result = await documentRepository.updateDocument(
        "test-uuid",
        titulo: "Updated Title",
        paciente: "John Doe",
      );

      expect(result.isSuccess(), true);
      final document = result.tryGetSuccess()!;
      expect(document.uuid, "test-uuid");
      expect(document.titulo, "Updated Title");

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
    });
  });

  group("moveToTrash", () {
    test("returns Error when document doesn't exist on server", () async {
      final testError = Exception("Document not found");
      when(
        () => documentApiClient.trashDocument(any()),
      ).thenAnswer((_) async => Result.error(testError));

      final result = await documentRepository.moveToTrash("non-existent-uuid");

      expect(result.isError(), true);
      expect(result.tryGetError(), testError);
    });

    test("trashes document on server and updates cache", () async {
      when(
        () => documentApiClient.trashDocument(any()),
      ).thenAnswer((_) async => const Result.success(null));

      when(
        () => localDatabase.trashDocument(any()),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await documentRepository.moveToTrash("test-uuid");

      expect(result.isSuccess(), true);

      verify(() => documentApiClient.trashDocument("test-uuid")).called(1);
      verify(() => localDatabase.trashDocument("test-uuid")).called(1);
    });
  });
}
