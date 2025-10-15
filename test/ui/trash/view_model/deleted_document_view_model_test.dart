import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/trash/view_models/deleted_document_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../../testing/mocks/repositories/mock_trash_repository.dart';

void main() {
  late DeletedDocumentViewModel viewModel;
  late TrashRepository mockTrashRepository = MockTrashRepository();
  final documentUuid = "test-uuid";
  setUp(() {
    viewModel = DeletedDocumentViewModel(
      documentUuid: documentUuid,
      trashRepository: mockTrashRepository,
    );
  });

  group("load document", () {
    setUp(() {});
    test(
      "gets document with specified UUID and stores it in the view model",
      () async {
        when(
          () => mockTrashRepository.getTrashDocument(documentUuid),
        ).thenAnswer(
          (_) async => Success(
            Document(
              uuid: documentUuid,
              paciente: "Paciente Teste",
              dataDocumento: DateTime(2023, 1, 1),
              createdAt: DateTime(2023, 1, 1),
            ),
          ),
        );
        // act
        viewModel.loadDocument.execute();
        await Future.delayed(const Duration(milliseconds: 100));

        // assert
        final response = viewModel.loadDocument.value;
        expect(response, isNotNull);
        expect(response?.tryGetSuccess(), isNotNull);
        expect(response?.tryGetSuccess()?.uuid, documentUuid);
      },
    );

    test("stores error in view model when repository returns error", () async {
      when(
        () => mockTrashRepository.getTrashDocument(documentUuid),
      ).thenAnswer((_) async => Error(Exception("Failed to load document")));

      // act
      viewModel.loadDocument.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // assert
      final response = viewModel.loadDocument.value;
      expect(response, isNotNull);
      expect(response?.isError(), isTrue);
    });
  });

  test("triggers document deletion when deleteDocument is called", () async {
    when(
      () => mockTrashRepository.destroyTrashDocument(documentUuid),
    ).thenAnswer((_) async => Success(null));

    // act
    viewModel.deleteDocumentForever.execute();
    await Future.delayed(const Duration(milliseconds: 100));

    // assert
    final response = viewModel.deleteDocumentForever.value;
    expect(response, isNotNull);
    expect(response?.isSuccess(), isTrue);
  });

  test(
    "triggers document restoration when restoreDocument is called",
    () async {
      when(
        () => mockTrashRepository.restoreTrashDocument(documentUuid),
      ).thenAnswer((_) async => Success(null));

      // act
      viewModel.restoreDocument.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // assert
      final response = viewModel.restoreDocument.value;
      expect(response, isNotNull);
      expect(response?.isSuccess(), isTrue);
    },
  );
}
