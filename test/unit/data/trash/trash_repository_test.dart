import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository_impl.dart';
import 'package:minha_saude_frontend/app/data/services/api/document/models/document_api_model.dart';
import 'package:minha_saude_frontend/app/data/services/api/trash/trash_api_client.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockTrashApiClient extends Mock implements TrashApiClient {}

void main() {
  late TrashApiClient trashApiClient;
  late TrashRepository trashRepository;
  setUp(() {
    trashApiClient = MockTrashApiClient();
    trashRepository = TrashRepositoryImpl(trashApiClient: trashApiClient);
  });

  group("List documents in trash", () {
    test("should return a list of documents from the API", () async {
      // Arrange
      when(() => trashApiClient.listTrashDocuments()).thenAnswer(
        (_) async => Result.success([
          _makeDefaultDocumentApiModel(), //
        ]),
      );

      // Act
      final result = await trashRepository.listTrashDocuments();

      // Assert
      expect(result, isA<Result<List<Document>, Exception>>());
      result.when(
        (data) {
          expect(data, isA<List<Document>>());
          expect(data.first, _defaultDocument());
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
      // Arrange
      when(() => trashApiClient.listTrashDocuments()).thenAnswer(
        (_) async => Success([
          _makeDefaultDocumentApiModel(), //
        ]),
      );

      // Act
      final result1 = await trashRepository.listTrashDocuments();

      when(() => trashApiClient.listTrashDocuments()).thenAnswer(
        (_) async => Success([
          DocumentApiModel(uuid: "alternative", createdAt: DateTime.now()),
        ]),
      );

      final result2 = await trashRepository.listTrashDocuments();

      // Assert
      // Did not query API again
      result1.when((data1) {
        result2.when((data2) {
          expect(data1, equals(data2));
        }, (error) => fail("result2 should be success"));
      }, (error) => fail("result1 should be success"));
      verify(() => trashApiClient.listTrashDocuments()).called(1);
    });
  });

  group("Get document in trash by id", () {
    test("should return a document from the API", () async {
      // Arrange
      when(
        () => trashApiClient.getTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.success(_makeDefaultDocumentApiModel()));

      // Act
      final result = await trashRepository.getTrashDocument("test-uuid");

      // Assert
      expect(result, isA<Result<Document, Exception>>());
      result.when(
        (data) {
          expect(data, isA<Document>());
          expect(data, _defaultDocument());
        },
        (error) {
          fail("Expected success, but got error: $error");
        },
      );
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.getTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.getTrashDocument("test-uuid");

      // Assert
      verify(() => trashApiClient.getTrashDocument("test-uuid")).called(1);
      result.whenSuccess((data) {
        fail("Expected error, but got data: $data");
      });
    });
  });

  group("Restore document in trash by id", () {
    test("should return success if the API call succeeds", () async {
      // Arrange
      when(
        () => trashApiClient.restoreTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.success(null));

      // Act
      final result = await trashRepository.restoreTrashDocument("test-uuid");

      // Assert
      verify(() => trashApiClient.restoreTrashDocument("test-uuid")).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.restoreTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.restoreTrashDocument("test-uuid");

      // Assert
      result.when((data) {
        fail("Expected error, but got success");
      }, (error) {});
    });
  });

  group("Permanently delete document in trash by id", () {
    test("should return success if the API call succeeds", () async {
      // Arrange
      when(
        () => trashApiClient.destroyTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.success(null));

      // Act
      final result = await trashRepository.destroyTrashDocument("test-uuid");

      // Assert
      verify(() => trashApiClient.destroyTrashDocument("test-uuid")).called(1);
      expect(result, isA<Result<void, Exception>>());
      expect(result.isError(), false);
    });

    test("should return an Error if the API call fails", () async {
      // Arrange
      when(
        () => trashApiClient.destroyTrashDocument("test-uuid"),
      ).thenAnswer((_) async => Result.error(Exception("API error")));

      // Act
      final result = await trashRepository.destroyTrashDocument("test-uuid");

      // Assert
      result.when((data) {
        fail("Expected error, but got success");
      }, (error) {});
    });
  });
}

Document _defaultDocument() {
  return Document(
    uuid: "test-uuid",
    titulo: "Test Document",
    paciente: "John Doe",
    medico: "Dr. Smith",
    tipo: "Prescription",
    dataDocumento: DateTime(2023, 1, 1),
    createdAt: DateTime(2023, 1, 2),
    deletedAt: DateTime(2023, 1, 3),
  );
}

DocumentApiModel _makeDefaultDocumentApiModel() {
  return DocumentApiModel(
    uuid: "test-uuid",
    titulo: "Test Document",
    nomePaciente: "John Doe",
    nomeMedico: "Dr. Smith",
    tipoDocumento: "Prescription",
    dataDocumento: DateTime(2023, 1, 1),
    createdAt: DateTime(2023, 1, 2),
    deletedAt: DateTime(2023, 1, 3),
  );
}
