import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/data/repositories/trash/trash_repository.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/trash/view_models/deleted_document_view_model.dart';
import 'package:minha_saude_frontend/app/ui/trash/widgets/deleted_document_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/repositories/mock_trash_repository.dart';
import '../../../../testing/models/document.dart';
import '../../../../testing/utils/format.dart';

void main() {
  // [UNIT] Shows document details as text
  late Widget view;
  late DeletedDocumentViewModel viewModel;
  late TrashRepository trashRepository;
  late Document mockDocument;

  setUp(() {
    mockDocument = randomDocument(isDeleted: true);

    trashRepository = MockTrashRepository();
    when(
      () => trashRepository.getTrashDocument(mockDocument.uuid),
    ).thenAnswer((_) async => Success(mockDocument));

    viewModel = DeletedDocumentViewModel(
      documentUuid: mockDocument.uuid,
      trashRepository: trashRepository,
    );
    view = testApp(
      Scaffold(body: DeletedDocumentView(viewModelFactory: () => viewModel)),
    );
  });

  testWidgets("shows document details as text", (tester) async {
    await tester.pumpWidget(view);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(mockDocument.deletedAt, isNotNull);
    expect(find.text(formatDate(mockDocument.deletedAt!)), findsOneWidget);
    if (mockDocument.medico != null) {
      expect(find.text(mockDocument.medico!), findsOneWidget);
    }
    if (mockDocument.paciente != null) {
      expect(find.text(mockDocument.paciente!), findsOneWidget);
    }
    if (mockDocument.tipo != null) {
      expect(find.text(mockDocument.tipo!), findsOneWidget);
    }

    // For some reason (command_it), disposing the view and imediately ending the test
    // causes an error. So we pump a dummy widget and wait a bit.
    await tester.pumpWidget(SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
