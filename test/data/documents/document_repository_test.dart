import 'dart:io';
import 'dart:typed_data';

import 'package:minha_saude_frontend/app/data/repositories/document/cache/document_file_cache_store.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/cache/document_list_cache_store.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/deprecating/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/models/document_db_model.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import 'package:minha_saude_frontend/app/data/services/api/deprecating/document/document_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/doc_scanner/document_scanner.dart';
import 'package:minha_saude_frontend/app/data/services/local/file_system_service/file_system_service.dart';

import '../../../testing/mocks/mock_file.dart';
import '../../../testing/models/document.dart';

class MockDocumentApiClient extends Mock implements DocumentApiClient {}

class MockDocumentScanner extends Mock implements DocumentScanner {}

class MockCacheDatabase extends Mock implements CacheDatabase {
  @override
  Future<void> init() async {}
}

class MockFileSystemService extends Mock implements FileSystemService {}

void main() {
  late DocumentApiClient documentApiClient;
  late DocumentScanner documentScanner;
  late CacheDatabase localDatabase;
  late FileSystemService fileSystemService;
  late DocumentRepositoryImpl documentRepository;
  late DocumentListCacheStore documentListCache;
  late DocumentFileCacheStore documentFileCache;

  setUpAll(() {
    registerFallbackValue(File("file.pdf"));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    documentScanner = MockDocumentScanner();
    fileSystemService = MockFileSystemService();
    documentApiClient = MockDocumentApiClient();
    localDatabase = MockCacheDatabase();
    documentListCache = DocumentListCacheStore();
    documentFileCache = DocumentFileCacheStore();

    when(
      () => localDatabase.upsertDocument(
        any(),
        titulo: any(named: 'titulo'),
        tipo: any(named: 'tipo'),
        paciente: any(named: 'paciente'),
        medico: any(named: 'medico'),
        dataDocumento: any(named: 'dataDocumento'),
        cachedAt: any(named: 'cachedAt'),
        deletedAt: any(named: 'deletedAt'),
        createdAt: any(named: 'createdAt'),
      ),
    ).thenAnswer((invocation) async {
      final cachedAt = invocation.namedArguments[#cachedAt] as DateTime?;
      return Success(
        DocumentDbModel(
          uuid: invocation.positionalArguments[0] as String,
          titulo: invocation.namedArguments[#titulo] as String,
          paciente: invocation.namedArguments[#paciente] as String?,
          medico: invocation.namedArguments[#medico] as String?,
          tipo: invocation.namedArguments[#tipo] as String?,
          dataDocumento: invocation.namedArguments[#dataDocumento] as DateTime?,
          createdAt: invocation.namedArguments[#createdAt] as DateTime,
          deletedAt: invocation.namedArguments[#deletedAt] as DateTime?,
          cachedAt: cachedAt ?? DateTime.now(),
        ),
      );
    });

    documentRepository = DocumentRepositoryImpl(
      documentScanner: documentScanner,
      fileSystemService: fileSystemService,
      documentApiClient: documentApiClient,
      localDatabase: localDatabase,
      documentFileCache: documentFileCache,
      documentListCache: documentListCache,
    );
  });

  group("Document Scanner and Picker", () {
    test("calls scanPdf function and returns file", () async {
      var file = File("/doc/123.pdf");
      when(() => documentScanner.scanPdf()).thenAnswer((_) async => file);

      final result = await documentScanner.scanPdf();

      expect(result, isA<File>());
      expect(result?.path, file.path);
      verify(() => documentScanner.scanPdf()).called(1);
    });

    test("returns null when scanPdf is cancelled", () async {
      // Hook mockery to track scanPdf function calls but do nothing
      when(() => documentScanner.scanPdf()).thenAnswer((_) async => null);

      // Call pickDocumentFile function
      final result = await documentScanner.scanPdf();

      // Assert scanPdf function was called
      verify(() => documentScanner.scanPdf()).called(1);
      expect(result, isNull);
    });

    test("calls pickPdfFile function and returns file", () async {
      // Hook mockery to track pickPdfFile function calls but do nothing
      when(
        () => fileSystemService.pickPdfFile(),
      ).thenAnswer((_) async => File("/doc/456.pdf"));

      // Call pickDocumentFile function
      final result = await fileSystemService.pickPdfFile();

      // Assert pickPdfFile function was called
      verify(() => fileSystemService.pickPdfFile()).called(1);
      expect(result, isA<File>());
      expect((result as File).path, "/doc/456.pdf");
    });
    test("returns null when pickPdfFile is cancelled", () async {
      // Hook mockery to track scanPdf function calls but do nothing
      when(() => fileSystemService.pickPdfFile()).thenAnswer((_) async => null);

      // Call pickDocumentFile function
      final result = await fileSystemService.pickPdfFile();

      // Assert scanPdf function was called
      verify(() => fileSystemService.pickPdfFile()).called(1);
      expect(result, isNull);
    });
  });

  group("Document Upload", () {
    late DocumentApiModel mockUploadedDocument;
    late MockFile mockUploadedFile;
    // late File fakeStoredFile;

    setUp(() {
      mockUploadedDocument = _mapToApiModel(randomDocument());

      mockUploadedFile = MockFile();
      // fakeStoredFile = File("/documents/test-uuid-123.pdf");

      when(
        () => mockUploadedFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(
        () => fileSystemService.storeDocument(any(), any()),
      ).thenAnswer((_) async => Success(mockUploadedFile));
      // when(
      //   () => fileSystemService.getDocument(any()),
      // ).thenAnswer((_) async => Success(fakeStoredFile));

      when(
        () => documentApiClient.uploadDocument(
          file: any(named: 'file'),
          titulo: any(named: 'titulo'),
          nomePaciente: any(named: 'nomePaciente'),
          nomeMedico: any(named: 'nomeMedico'),
          tipoDocumento: any(named: 'tipoDocumento'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      ).thenAnswer((invocation) async {
        var i = invocation;
        var doc = mockUploadedDocument;
        return Success(
          DocumentApiModel(
            uuid: doc.uuid,
            titulo: i.namedArguments[#titulo] as String,
            nomePaciente: i.namedArguments[#nomePaciente] as String?,
            nomeMedico: i.namedArguments[#nomeMedico] as String?,
            tipoDocumento: i.namedArguments[#tipoDocumento] as String?,
            dataDocumento: i.namedArguments[#dataDocumento] as DateTime?,
            createdAt: doc.createdAt,
          ),
        );
      });
    });

    Future<Result<Document, Exception>> uploadMockDocument(
      DocumentApiModel doc,
    ) {
      return documentRepository.uploadDocument(
        mockUploadedFile,
        paciente: doc.nomePaciente,
        titulo: doc.titulo,
        tipo: doc.tipoDocumento,
        medico: doc.nomeMedico,
        dataDocumento: doc.dataDocumento,
      );
    }

    test("uploads document to API client with correct parameters", () async {
      var doc = mockUploadedDocument;
      final result = await uploadMockDocument(doc);

      expect(result.isSuccess(), true);
      verify(
        () => documentApiClient.uploadDocument(
          file: mockUploadedFile,
          titulo: doc.titulo,
          nomePaciente: doc.nomePaciente,
          nomeMedico: doc.nomeMedico,
          tipoDocumento: doc.tipoDocumento,
          dataDocumento: doc.dataDocumento,
        ),
      ).called(1);
    });

    test("stores file locally with correct UUID and bytes", () async {
      var doc = mockUploadedDocument;
      var docBytes = await mockUploadedFile.readAsBytes();
      final result = await uploadMockDocument(doc);

      expect(result.isSuccess(), true);
      verify(
        () => fileSystemService.storeDocument(doc.uuid, docBytes),
      ).called(1);
    });

    test("caches document metadata in database", () async {
      var doc = mockUploadedDocument;
      final result = await uploadMockDocument(doc);

      expect(result.isSuccess(), true);
      verify(() {
        return localDatabase.upsertDocument(
          doc.uuid,
          titulo: doc.titulo,
          paciente: doc.nomePaciente,
          medico: doc.nomeMedico,
          tipo: doc.tipoDocumento,
          dataDocumento: doc.dataDocumento,
          createdAt: doc.createdAt,
          deletedAt: doc.deletedAt,
          cachedAt: any(named: 'cachedAt'),
        );
      }).called(1);
    });

    test("handles api error gracefully", () async {
      when(
        () => documentApiClient.uploadDocument(
          file: any(named: 'file'),
          titulo: any(named: 'titulo'),
          nomePaciente: any(named: 'nomePaciente'),
          nomeMedico: any(named: 'nomeMedico'),
          tipoDocumento: any(named: 'tipoDocumento'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      ).thenAnswer((_) async => Result.error(Exception("API failure")));

      var doc = mockUploadedDocument;
      final result = await uploadMockDocument(doc);

      expect(result.isError(), true);
      verifyNever(() {
        return localDatabase.upsertDocument(
          any(),
          titulo: any(named: 'titulo'),
          paciente: any(named: 'paciente'),
          medico: any(named: 'medico'),
          tipo: any(named: 'tipo'),
          dataDocumento: any(named: 'dataDocumento'),
          createdAt: any(named: 'createdAt'),
          deletedAt: any(named: 'deletedAt'),
          cachedAt: any(named: 'cachedAt'),
        );
      });
    });

    test("ignores caching errors (non-essential)", () async {
      when(
        () => fileSystemService.storeDocument(any(), any()),
      ).thenAnswer((_) async => Error(Exception("File system error")));
      when(
        () => localDatabase.upsertDocument(
          any(),
          titulo: any(named: 'titulo'),
          cachedAt: any(named: 'cachedAt'),
          dataDocumento: any(named: 'dataDocumento'),
          deletedAt: any(named: 'deletedAt'),
          medico: any(named: 'medico'),
          paciente: any(named: 'paciente'),
          tipo: any(named: 'tipo'),
          createdAt: any(named: 'createdAt'),
        ),
      ).thenAnswer((_) async => Result.error(Exception("DB failure")));

      var doc = mockUploadedDocument;
      final result = await uploadMockDocument(doc);

      expect(result.isSuccess(), true);
    });
  });

  group("Get Document List", () {
    late List<DocumentApiModel> mockDocumentsInAPI;
    late List<DocumentDbModel> mockDocumentsInLocal;

    setUp(() {
      mockDocumentsInAPI = [
        _mapToApiModel(randomDocument()),
        _mapToApiModel(randomDocument()),
        _mapToApiModel(randomDocument(isDeleted: true)),
      ];
      mockDocumentsInLocal = [
        _mapToDbModel(randomDocument()),
        _mapToDbModel(randomDocument()),
        _mapToDbModel(randomDocument(isDeleted: true)),
      ];

      when(
        () => documentApiClient.listDocuments(),
      ).thenAnswer((_) async => Result.success(mockDocumentsInAPI));
      when(
        () => localDatabase.listDocuments(),
      ).thenAnswer((_) async => Result.success(mockDocumentsInLocal));
    });

    test("returns documents from ApiClient when available", () async {
      final result = await documentRepository.listDocuments();

      expect(result.isSuccess(), true);
      final documents = result.tryGetSuccess()!;
      expect(documents.first.uuid, mockDocumentsInAPI.first.uuid);
    });

    test("returns documents from local database when API fails", () async {
      when(
        () => documentApiClient.listDocuments(),
      ).thenAnswer((_) async => Result.error(Exception("API failure")));

      final result = await documentRepository.listDocuments();

      expect(result.isSuccess(), true);
      final documents = result.tryGetSuccess()!;
      expect(documents.first.uuid, mockDocumentsInLocal.first.uuid);

      verify(() => documentApiClient.listDocuments()).called(1);
      verify(() => localDatabase.listDocuments()).called(1);
    });

    test(
      "caches results and doesn't call API again on subsequent calls",
      () async {
        final result1 = await documentRepository.listDocuments();
        final result2 = await documentRepository.listDocuments();

        verify(
          () => documentApiClient.listDocuments(),
        ).called(1); // Only first call
        verifyNever(() => localDatabase.listDocuments()); // Did not call DB

        expect(result2.isSuccess(), true);
        expect(result1.tryGetSuccess()!.first, result2.tryGetSuccess()!.first);
      },
    );

    test("calls ApiClient again when forceRefresh is true", () async {
      when(
        () => documentApiClient.listDocuments(),
      ).thenAnswer((_) async => Result.success(mockDocumentsInAPI));

      final result1 = await documentRepository.listDocuments();
      final result2 = await documentRepository.listDocuments(
        forceRefresh: true,
      );

      verify(() => documentApiClient.listDocuments()).called(2);
      expect(result2.isSuccess(), true);
      expect(result1.tryGetSuccess()!.first, result2.tryGetSuccess()!.first);
    });
  });

  group("Get Document Metadata", () {
    late Document mockDocumentInServer;
    late Document mockDocumentInLocal;
    setUp(() {
      mockDocumentInServer = randomDocument();
      mockDocumentInLocal = randomDocument();

      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => Success(_mapToDbModel(mockDocumentInLocal)));
      when(
        () => documentApiClient.getDocument(any()),
      ).thenAnswer((_) async => Success(_mapToApiModel(mockDocumentInServer)));
    });

    /**
     * returns document from in-memory cache without calling DB or API if available
     * returns document from localDB if it is not stale
     * returns document from API if localDB is stale
     * returns document from API if localDB is unavailable
     * stores document in localDB after API fetch
     * returns error when both API and localDB are unavailable
     * returns document from localDB while stale if API is unavailable
     * returns document from API ignoring localDB and cache if forceRefresh is true
    */

    test(
      "returns document from in-memory cache without calling DB or API if available",
      () async {
        // Populate in-memory cache
        final document = randomDocument();
        documentListCache.set([document]);

        final result = await documentRepository.getDocumentMeta(document.uuid);

        // Assert cache was used
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), document);
        verifyNever(() => documentApiClient.getDocument(any()));
        verifyNever(() => localDatabase.getDocument(any()));
      },
    );

    test("returns document from localDB if it is not stale", () async {
      // By default, cache is not stale in setUp()
      final result = await documentRepository.getDocumentMeta(
        mockDocumentInLocal.uuid,
      );

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()!.uuid, mockDocumentInLocal.uuid);
      verify(
        () => localDatabase.getDocument(mockDocumentInLocal.uuid),
      ).called(1);
      verifyNever(() => documentApiClient.getDocument(any()));
    });

    test("returns document from API if localDB is stale", () async {
      // Simulate stale
      when(() => localDatabase.getDocument(any())).thenAnswer(
        (_) async => Success(
          _mapToDbModel(mockDocumentInLocal).copyWith(
            cachedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ),
      );

      final result = await documentRepository.getDocumentMeta(
        mockDocumentInLocal.uuid,
      );

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()!.uuid, mockDocumentInServer.uuid);
      verify(
        () => documentApiClient.getDocument(mockDocumentInLocal.uuid),
      ).called(1);
    });

    test("returns document from API if localDB is unavailable", () async {
      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("Local DB failure")));

      final result = await documentRepository.getDocumentMeta(
        mockDocumentInLocal.uuid,
      );

      expect(result.isSuccess(), true);
      expect(result.tryGetSuccess()!.uuid, mockDocumentInServer.uuid);
      verify(
        () => documentApiClient.getDocument(mockDocumentInLocal.uuid),
      ).called(1);
    });

    test("stores document in localDB after API fetch", () async {
      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("Local DB failure")));

      final result = await documentRepository.getDocumentMeta(
        mockDocumentInServer.uuid,
      );

      expect(result.isSuccess(), true);
      verify(
        () => localDatabase.upsertDocument(
          mockDocumentInServer.uuid,
          titulo: mockDocumentInServer.titulo,
          paciente: mockDocumentInServer.paciente,
          medico: mockDocumentInServer.medico,
          tipo: mockDocumentInServer.tipo,
          dataDocumento: mockDocumentInServer.dataDocumento,
          createdAt: mockDocumentInServer.createdAt,
          deletedAt: mockDocumentInServer.deletedAt,
          cachedAt: any(named: 'cachedAt'),
        ),
      ).called(1);
    });

    test("returns error when both API and localDB are unavailable", () async {
      // Simulate localDB and API failure
      // Cache is already null
      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("Local DB failure")));
      when(
        () => documentApiClient.getDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("API failure")));

      // Attempt to get document
      final result = await documentRepository.getDocumentMeta(
        mockDocumentInLocal.uuid,
      );

      // Expect error
      expect(result.isError(), true);
    });

    test(
      "returns document from localDB while stale if API is unavailable",
      () async {
        // Simulate stale
        when(() => localDatabase.getDocument(any())).thenAnswer(
          (_) async => Success(
            _mapToDbModel(mockDocumentInLocal).copyWith(
              cachedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ),
        );
        // API Unavailable
        when(
          () => documentApiClient.getDocument(any()),
        ).thenAnswer((_) async => Result.error(Exception("API failure")));

        final result = await documentRepository.getDocumentMeta(
          mockDocumentInLocal.uuid,
        );

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess()!.uuid, mockDocumentInLocal.uuid);
      },
    );

    test(
      "returns document from API ignoring localDB if forceRefresh is true",
      () async {
        final result = await documentRepository.getDocumentMeta(
          mockDocumentInLocal.uuid,
          forceRefresh: true,
        );

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess()!.uuid, mockDocumentInServer.uuid);
        verify(
          () => documentApiClient.getDocument(mockDocumentInLocal.uuid),
        ).called(1);
      },
    );
  });

  group("Get Document File", () {
    late File mockFile;
    setUp(() {
      mockFile = File('/path/to/file');
    });
    /**
     * returns file in cache without querying server or file system
     * returns file in file system and caches without querying server
     * downloads from API and stores locally when cache is unavailable
     * returns error when document doesn't exist on server, file system or cache
     */

    test(
      "returns file in cache without querying server or file system",
      () async {
        // Insert into cache
        documentFileCache.set("test-uuid", mockFile);

        // Act
        final result = await documentRepository.getDocumentFile("test-uuid");

        // assert
        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), mockFile);

        verifyNever(() => documentApiClient.downloadDocument(any()));
        verifyNever(() => fileSystemService.getDocument(any()));
      },
    );

    test(
      "returns file in file system and caches without querying server",
      () async {
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => Success(mockFile));

        final result = await documentRepository.getDocumentFile("test-uuid");

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), mockFile);
        verifyNever(() => documentApiClient.downloadDocument(any()));
      },
    );

    test(
      "downloads from API and stores locally when cache is unavailable",
      () async {
        final mockFileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(
          () => documentApiClient.downloadDocument(any()),
        ).thenAnswer((_) async => Success(mockFileBytes));
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => const Success(null));

        when(
          () => fileSystemService.storeDocument(any(), any()),
        ).thenAnswer((_) async => Success(mockFile));

        final result = await documentRepository.getDocumentFile("test-uuid");

        expect(result.isSuccess(), true);
        expect(result.tryGetSuccess(), same(mockFile));

        verify(() => documentApiClient.downloadDocument("test-uuid")).called(1);
      },
    );

    test(
      "returns error when document doesn't exist on server, file system or cache",
      () async {
        // Cache is empty by default
        when(
          () => documentApiClient.downloadDocument(any()),
        ).thenAnswer((_) async => Result.error(Exception("API failure")));
        when(
          () => fileSystemService.getDocument(any()),
        ).thenAnswer((_) async => const Success(null));

        final result = await documentRepository.getDocumentFile("test-uuid");

        expect(result.isError(), true);
      },
    );

    test("handles file system errors gracefully", () async {
      // Cache is empty by default
      when(
        () => documentApiClient.downloadDocument(any()),
      ).thenAnswer((_) async => Error(Exception("API failure")));
      when(
        () => fileSystemService.getDocument(any()),
      ).thenAnswer((_) async => Error(Exception("File system error")));

      final result = await documentRepository.getDocumentFile("test-uuid");

      expect(result.isError(), true);
    });
  });

  group("Update Document Data", () {
    late DocumentApiModel mockUpdatedDocument;
    setUp(() {
      mockUpdatedDocument = _mapToApiModel(randomDocument());

      when(
        () => documentApiClient.updateDocument(
          any(),
          titulo: any(named: 'titulo'),
          nomePaciente: any(named: 'nomePaciente'),
          nomeMedico: any(named: 'nomeMedico'),
          tipoDocumento: any(named: 'tipoDocumento'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      ).thenAnswer((invocation) async {
        var i = invocation;
        var doc = mockUpdatedDocument;

        return Success(
          DocumentApiModel(
            uuid: i.positionalArguments[0] as String,
            titulo: i.namedArguments[#titulo] as String? ?? doc.titulo,
            nomePaciente: i.namedArguments[#nomePaciente] as String?,
            nomeMedico: i.namedArguments[#nomeMedico] as String?,
            tipoDocumento: i.namedArguments[#tipoDocumento] as String?,
            dataDocumento: i.namedArguments[#dataDocumento] as DateTime?,
            createdAt: doc.createdAt,
            deletedAt: doc.deletedAt,
          ),
        );
      });
    });
    /**
     * updates document on server and renews cache
     * returns Error when document doesn't exist
     */

    test("updates document on server and renews cache", () async {
      var doc = mockUpdatedDocument;

      final result = await documentRepository.updateDocument(
        doc.uuid,
        titulo: doc.titulo,
        paciente: doc.nomePaciente,
        dataDocumento: doc.dataDocumento,
        medico: doc.nomeMedico,
        tipo: doc.tipoDocumento,
      );

      final document = result.tryGetSuccess();
      expect(result.isSuccess(), true);
      expect(document!.uuid, doc.uuid);
      expect(document.titulo, doc.titulo);
      expect(document.paciente, doc.nomePaciente);
      expect(document.dataDocumento, doc.dataDocumento);
      expect(document.medico, doc.nomeMedico);
      expect(document.tipo, doc.tipoDocumento);

      verify(
        () => localDatabase.upsertDocument(
          doc.uuid,
          titulo: doc.titulo,
          paciente: doc.nomePaciente,
          medico: doc.nomeMedico,
          tipo: doc.tipoDocumento,
          dataDocumento: doc.dataDocumento,
          createdAt: doc.createdAt,
          deletedAt: doc.deletedAt,
          cachedAt: any(named: 'cachedAt'),
        ),
      ).called(1);
    });

    test("handles error when document doesn't exist", () async {
      var doc = mockUpdatedDocument;
      when(
        () => documentApiClient.updateDocument(
          any(),
          titulo: any(named: 'titulo'),
          nomePaciente: any(named: 'nomePaciente'),
          nomeMedico: any(named: 'nomeMedico'),
          tipoDocumento: any(named: 'tipoDocumento'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      ).thenAnswer((_) async => Error(Exception("Document not found")));

      final result = await documentRepository.updateDocument(
        doc.uuid,
        titulo: doc.titulo,
        paciente: doc.nomePaciente,
        dataDocumento: doc.dataDocumento,
        medico: doc.nomeMedico,
        tipo: doc.tipoDocumento,
      );

      expect(result.isError(), true);
    });

    test("does not update local cache if server update fails", () async {
      var doc = mockUpdatedDocument;
      when(
        () => documentApiClient.updateDocument(
          any(),
          titulo: any(named: 'titulo'),
          nomePaciente: any(named: 'nomePaciente'),
          nomeMedico: any(named: 'nomeMedico'),
          tipoDocumento: any(named: 'tipoDocumento'),
          dataDocumento: any(named: 'dataDocumento'),
        ),
      ).thenAnswer((_) async => Error(Exception("Document not found")));

      await documentRepository.updateDocument(
        doc.uuid,
        titulo: doc.titulo,
        paciente: doc.nomePaciente,
        dataDocumento: doc.dataDocumento,
        medico: doc.nomeMedico,
        tipo: doc.tipoDocumento,
      );

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
          cachedAt: any(named: 'cachedAt'),
        ),
      );
    });
  });

  group("Delete Document", () {
    const String testUuid = "test-uuid";
    setUp(() {
      when(
        () => documentApiClient.trashDocument(any()),
      ).thenAnswer((_) async => const Success(null));

      when(
        () => localDatabase.trashDocument(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    test("deletes document on server and updates cache", () async {
      final result = await documentRepository.moveToTrash(testUuid);

      expect(result.isSuccess(), true);

      verify(() => documentApiClient.trashDocument(testUuid)).called(1);
      verify(() => localDatabase.trashDocument(testUuid)).called(1);
    });

    test("returns Error when document doesn't exist on server", () async {
      when(
        () => documentApiClient.trashDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("Document not found")));

      final result = await documentRepository.moveToTrash(testUuid);

      expect(result.isError(), true);
    });

    test("does not delete local document if server fails", () async {
      when(
        () => documentApiClient.trashDocument(any()),
      ).thenAnswer((_) async => Result.error(Exception("Document not found")));

      await documentRepository.moveToTrash(testUuid);

      verifyNever(() => localDatabase.trashDocument(testUuid));
    });
  });

  group("Cache disposal on command", () {
    test("clears in-memory cache and local database on disposal", () async {
      // Stuff to be cleared:
      // * In-memory document cache
      // * In-memory file cache
      // * Local Database
      // * Locally Stored Files
      when(() => localDatabase.clear()).thenAnswer((_) async => Success(null));
      when(
        () => fileSystemService.clearDocuments(),
      ).thenAnswer((_) async => Success(null));

      documentListCache.set([randomDocument()]);
      documentFileCache.set('fake-uuid', File('/path/to/file'));

      // Act
      await documentRepository.clearCache();

      // verify(() => documentListCache.clear()).called(1);
      expect(documentFileCache.get('fake-uuid'), isNull);
      // verify(() => documentFileCache.clear()).called(1);
      expect(documentListCache.get(), isNull);
      verify(() => localDatabase.clear()).called(1);
      verify(() => fileSystemService.clearDocuments()).called(1);
    });
  });
}

DocumentDbModel _mapToDbModel(Document doc) {
  return DocumentDbModel(
    uuid: doc.uuid,
    titulo: doc.titulo,
    paciente: doc.paciente,
    medico: doc.medico,
    tipo: doc.tipo,
    dataDocumento: doc.dataDocumento,
    createdAt: doc.createdAt,
    deletedAt: doc.deletedAt,
    cachedAt: DateTime.now(),
  );
}

DocumentApiModel _mapToApiModel(Document doc) {
  return DocumentApiModel(
    uuid: doc.uuid,
    titulo: doc.titulo,
    nomePaciente: doc.paciente,
    nomeMedico: doc.medico,
    tipoDocumento: doc.tipo,
    dataDocumento: doc.dataDocumento,
    createdAt: doc.createdAt,
    deletedAt: doc.deletedAt,
  );
}
