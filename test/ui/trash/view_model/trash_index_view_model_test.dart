import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/trash/view_models/trash_index_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../../testing/mocks/repositories/mock_trash_repository.dart';

void main() {
  late TrashRepository trashRepository;
  late TrashIndexViewModel viewModel;

  setUp(() {
    trashRepository = MockTrashRepository();
    viewModel = TrashIndexViewModel(trashRepository: trashRepository);
  });

  // gets document list and stores when load is executed
  test("gets document list and stores when load is executed", () async {
    // arrange
    final docList = [Document(uuid: "mock-uuid", createdAt: DateTime(2025))];
    when(
      () => trashRepository.listTrashDocuments(
        forceRefresh: any(named: "forceRefresh"),
      ),
    ).thenAnswer((_) async => Success(docList));

    // act
    viewModel.loadDocuments.execute(false);
    await Future.delayed(const Duration(milliseconds: 100));

    // assert
    verify(
      () => trashRepository.listTrashDocuments(forceRefresh: false),
    ).called(1);
    expect(viewModel.loadDocuments.value!.getOrThrow(), docList);
  });

  // stores error result when getting document list fails
  test("stores error result when getting document list fails", () async {
    // arrange
    when(
      () => trashRepository.listTrashDocuments(
        forceRefresh: any(named: "forceRefresh"),
      ),
    ).thenAnswer((_) async => Error(Exception("mock-error")));

    // act
    viewModel.loadDocuments.execute(false);
    await Future.delayed(const Duration(milliseconds: 100));

    // assert
    verify(
      () => trashRepository.listTrashDocuments(forceRefresh: false),
    ).called(1);
    expect(viewModel.loadDocuments.value!.tryGetError()!, isA<Exception>());
  });

  // reloads document list when reloadDocuments is called
  test("reloads document list when reloadDocuments is called", () async {
    // arrange
    final docList = [Document(uuid: "mock-uuid", createdAt: DateTime(2025))];
    when(
      () => trashRepository.listTrashDocuments(
        forceRefresh: any(named: "forceRefresh"),
      ),
    ).thenAnswer((_) async => Success(docList));

    // act
    viewModel.reloadDocuments();
    await Future.delayed(const Duration(milliseconds: 100));

    // assert
    expect(viewModel.loadDocuments.value, isA<Result<List, Exception>>());
    verify(
      () => trashRepository.listTrashDocuments(forceRefresh: true),
    ).called(1);
    expect(viewModel.loadDocuments.value!.getOrThrow(), docList);
  });

  // calls repository with force refresh true when reloadDocuments is called
  test(
    "calls repository with force refresh true when reloadDocuments is called",
    () async {
      // arrange
      when(
        () => trashRepository.listTrashDocuments(
          forceRefresh: any(named: "forceRefresh"),
        ),
      ).thenAnswer((_) async => Success([]));

      // act
      viewModel.reloadDocuments();
      await Future.delayed(const Duration(milliseconds: 100));

      // assert
      verify(
        () => trashRepository.listTrashDocuments(forceRefresh: true),
      ).called(1);
    },
  );
}
