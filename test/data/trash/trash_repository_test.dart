import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/document/models/document_api_model/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/clients/trash/trash_api_client.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/cache_database.dart';
import 'package:minha_saude_frontend/app/data/services/local/cache_database/models/document_db_model.dart';
import 'package:minha_saude_frontend/app/data/services/local/file_system_service/file_system_service.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../testing/models/document.dart';

class MockTrashApiClient extends Mock implements TrashApiClient {}

class MockCacheDatabase extends Mock implements CacheDatabase {}

class MockFileSystemService extends Mock implements FileSystemService {}

void main() {
  late TrashApiClient trashApiClient;
  late CacheDatabase localDatabase;
  late FileSystemService fileSystemService;
  late TrashRepository trashRepository;
  late Document mockDocument;

  setUp(() {
    trashApiClient = MockTrashApiClient();
    localDatabase = MockCacheDatabase();
    fileSystemService = MockFileSystemService();
    trashRepository = TrashRepositoryImpl(
      trashApiClient: trashApiClient,
      localDatabase: localDatabase,
      fileSystemService: fileSystemService,
    );

    // Create a deleted document for trash tests
    mockDocument = randomDocument(isDeleted: true);
  });

  group("List documents in trash", () {
    setUp(() {
      when(
        () => trashApiClient.listTrashDocuments(),
      ).thenAnswer((_) async => Result.success([_mapToApiModel(mockDocument)]));
    });

    test("should return a list of documents from the API", () async {
      // Act
      final result = await trashRepository.listTrashDocuments();

      // Assert
      expect(result, isA<Result<List<Document>, Exception>>());
      expect(result.isSuccess(), true);
      result.when(
        (data) {
          expect(data, isA<List<Document>>());
          expect(data.first.uuid, mockDocument.uuid);
          expect(data.first.titulo, mockDocument.titulo);
          expect(data.first.paciente, mockDocument.paciente);
        },
        (error) {
          fail("Expected success, but got error: $error");
        },
      );
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.listTrashDocuments(),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.listTrashDocuments();

      // Assert
      result.mapSuccess((data) {
        fail("Expected error, but got data: $data");
      });
    });

    test("should return cache if called more than once", () async {
      // Act
      final result1 = await trashRepository.listTrashDocuments();

      // Change API to return different data
      final alternativeDoc = randomDocument(isDeleted: true);
      when(
        () => trashApiClient.listTrashDocuments(),
      ).thenAnswer((_) async => Success([_mapToApiModel(alternativeDoc)]));

      final result2 = await trashRepository.listTrashDocuments();

      // Assert
      // Did not query API again - should return cached data
      result1.when((data1) {
        result2.when((data2) {
          expect(data1.first.uuid, equals(data2.first.uuid));
          expect(data1.first.uuid, mockDocument.uuid);
        }, (error) => fail("result2 should be success"));
      }, (error) => fail("result1 should be success"));
      verify(() => trashApiClient.listTrashDocuments()).called(1);
    });
  });

  group("Get document in trash by id", () {
    setUp(() {
      when(
        () => trashApiClient.getTrashDocument(any()),
      ).thenAnswer((_) async => Result.success(_mapToApiModel(mockDocument)));
    });

    test("should return a document from the API", () async {
      // Act
      final result = await trashRepository.getTrashDocument(mockDocument.uuid);

      // Assert
      expect(result, isA<Result<Document, Exception>>());
      result.when(
        (data) {
          expect(data, isA<Document>());
          expect(data.uuid, mockDocument.uuid);
          expect(data.titulo, mockDocument.titulo);
          expect(data.paciente, mockDocument.paciente);
        },
        (error) {
          fail("Expected success, but got error: $error");
        },
      );
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.getTrashDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.getTrashDocument(mockDocument.uuid);

      // Assert
      verify(
        () => trashApiClient.getTrashDocument(mockDocument.uuid),
      ).called(1);
      result.whenSuccess((data) {
        fail("Expected error, but got data: $data");
      });
    });
  });

  group("Restore document in trash by id", () {
    setUp(() {
      when(
        () => trashApiClient.restoreTrashDocument(any()),
      ).thenAnswer((_) async => Result.success(null));

      when(
        () => localDatabase.getDocument(any()),
      ).thenAnswer((_) async => Result.success(_mapToDbModel(mockDocument)));

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
          _mapToDbModel(mockDocument.copyWith(deletedAt: null)),
        ),
      );
    });

    test("should return success if the API call succeeds", () async {
      // Act
      final result = await trashRepository.restoreTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      verify(
        () => trashApiClient.restoreTrashDocument(mockDocument.uuid),
      ).called(1);
      verify(() => localDatabase.getDocument(mockDocument.uuid)).called(1);
      verify(
        () => localDatabase.upsertDocument(
          mockDocument.uuid,
          titulo: any(named: 'titulo'),
          paciente: any(named: 'paciente'),
          medico: any(named: 'medico'),
          tipo: any(named: 'tipo'),
          dataDocumento: any(named: 'dataDocumento'),
          createdAt: any(named: 'createdAt'),
          deletedAt: null,
          cachedAt: any(named: 'cachedAt'),
        ),
      ).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.restoreTrashDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.restoreTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      result.when((data) {
        fail("Expected error, but got success");
      }, (error) {});
      verifyNever(() => localDatabase.getDocument(any()));
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

    test("should succeed even if database update fails", () async {
      // Arrange
      when(
        () => localDatabase.getDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("DB error")));

      // Act
      final result = await trashRepository.restoreTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      verify(
        () => trashApiClient.restoreTrashDocument(mockDocument.uuid),
      ).called(1);
      verify(() => localDatabase.getDocument(mockDocument.uuid)).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });
  });

  group("Permanently delete document in trash by id", () {
    setUp(() {
      when(
        () => trashApiClient.destroyTrashDocument(any()),
      ).thenAnswer((_) async => Result.success(null));

      when(
        () => localDatabase.removeDocument(any()),
      ).thenAnswer((_) async => Result.success(null));

      when(
        () => fileSystemService.deleteDocument(any()),
      ).thenAnswer((_) async => Result.success(null));
    });

    test("should return success if the API call succeeds", () async {
      // Act
      final result = await trashRepository.destroyTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      verify(
        () => trashApiClient.destroyTrashDocument(mockDocument.uuid),
      ).called(1);
      verify(() => localDatabase.removeDocument(mockDocument.uuid)).called(1);
      verify(
        () => fileSystemService.deleteDocument(mockDocument.uuid),
      ).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.destroyTrashDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.destroyTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      result.when((data) {
        fail("Expected error, but got success");
      }, (error) {});
      verifyNever(() => localDatabase.removeDocument(any()));
      verifyNever(() => fileSystemService.deleteDocument(any()));
    });

    test("should succeed even if database or file removal fails", () async {
      // Arrange
      when(
        () => localDatabase.removeDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("DB error")));

      when(
        () => fileSystemService.deleteDocument(mockDocument.uuid),
      ).thenAnswer((_) async => Result.error(Exception("FS error")));

      // Act
      final result = await trashRepository.destroyTrashDocument(
        mockDocument.uuid,
      );

      // Assert
      verify(
        () => trashApiClient.destroyTrashDocument(mockDocument.uuid),
      ).called(1);
      verify(() => localDatabase.removeDocument(mockDocument.uuid)).called(1);
      verify(
        () => fileSystemService.deleteDocument(mockDocument.uuid),
      ).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });
  });
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
