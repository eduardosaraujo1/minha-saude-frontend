import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:minha_saude_frontend/app/ui/documents/view_models/upload/document_upload_view_model.dart';
import 'package:minha_saude_frontend/app/ui/documents/widgets/upload/document_upload_navigator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/app.dart';
import '../../../../testing/mocks/mock_file.dart';
import '../../../../testing/mocks/mock_go_router.dart';
import '../../../../testing/mocks/repositories/mock_document_repository.dart';
import '../../../../testing/models/document.dart';
import '../../../../testing/utils/command_it.dart';
import '../../../../testing/utils/format.dart';

void main() {
  late MockDocumentRepository mockDocumentRepository;
  late DocumentUploadViewModel viewModel;
  late MockFile mockFile;
  late MockGoRouter mockGoRouter;
  late Widget view;

  final Document document = randomDocument();

  setUpAll(() {
    registerFallbackValue(MockFile() as File);
  });

  setUp(() {
    mockFile = MockFile();
    mockDocumentRepository = MockDocumentRepository();
    mockGoRouter = MockGoRouter();

    // Arrange: mock file properties
    when(() => mockFile.path).thenReturn('/path/to/mock/document.pdf');
    when(() => mockFile.length()).thenAnswer((_) async => 1024);
    when(
      () => mockFile.readAsBytes(),
    ).thenAnswer((_) async => Uint8List.fromList([0, 1, 2, 3, 4, 5]));

    // Arrange: successful document upload by default
    when(
      () => mockDocumentRepository.uploadDocument(
        mockFile,
        titulo: any(named: 'titulo'),
        medico: any(named: 'medico'),
        paciente: any(named: 'paciente'),
        tipo: any(named: 'tipo'),
        dataDocumento: any(named: 'dataDocumento'),
      ),
    ).thenAnswer((_) async => Success(document));

    // Arrange: successful file picking by default
    when(
      () => mockDocumentRepository.pickDocumentFile(),
    ).thenAnswer((_) async => Success(mockFile));

    viewModel = DocumentUploadViewModel(
      type: DocumentUploadMethod.filePicker,
      documentRepository: mockDocumentRepository,
    );

    view = testApp(
      mockGoRouter: mockGoRouter,
      Scaffold(
        body: DocumentUploadNavigator(viewModelFactory: () => viewModel),
      ),
    );
  });

  group('Document Upload Flow', () {
    testWidgets('it completes the flow on valid setup', (tester) async {
      // Pump widget and wait for initial document load
      await tester.pumpWidget(view);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // ===== STEP 1: PREVIEW =====
      // Verify preview screen elements exist
      expect(find.byKey(const Key('btnConfirm')), findsOneWidget);
      expect(find.byKey(const Key('btnCancel')), findsOneWidget);
      expect(find.byKey(const Key('pdfCarousel')), findsOneWidget);

      // Tap confirm button to advance to title form
      await tester.tap(find.byKey(const Key('btnConfirm')));
      await tester.pumpAndSettle();

      // ===== STEP 2: TITLE FORM =====
      // Verify title form elements exist
      expect(find.byKey(const Key('inputTitle')), findsOneWidget);
      expect(find.byKey(const Key('btnNext')), findsOneWidget);

      // Fill in the title
      final titleField = find.byKey(const Key('inputTitle'));
      await tester.enterText(titleField, document.titulo);
      await tester.pump();

      // Tap next button to advance to metadata form
      await tester.tap(find.byKey(const Key('btnNext')));
      await tester.pumpAndSettle();

      // ===== STEP 3: METADATA FORM =====
      // Verify metadata form elements exist
      expect(find.byKey(const Key('inputNomePaciente')), findsOneWidget);
      expect(find.byKey(const Key('inputNomeMedico')), findsOneWidget);
      expect(find.byKey(const Key('inputTipoDocumento')), findsOneWidget);
      expect(find.byKey(const Key('inputDataDocumento')), findsOneWidget);
      expect(find.byKey(const Key('btnSkip')), findsOneWidget);
      expect(find.byKey(const Key('btnSubmit')), findsOneWidget);

      // Fill in metadata
      await tester.enterText(
        find.byKey(const Key('inputNomePaciente')),
        document.paciente ?? '',
      );
      await tester.enterText(
        find.byKey(const Key('inputNomeMedico')),
        document.medico ?? '',
      );
      await tester.enterText(
        find.byKey(const Key('inputTipoDocumento')),
        document.tipo ?? '',
      );
      final date = tester.widget<TextFormField>(
        find.byKey(const Key('inputDataDocumento')),
      );
      date.controller?.text = document.dataDocumento != null
          ? formatDate(document.dataDocumento!)
          : '';
      await tester.pumpAndSettle();

      // Tap submit button
      await tester.tap(find.byKey(const Key('btnSubmit')));
      await tester.pumpAndSettle();

      // Verify that the upload was initiated
      verify(
        () => mockDocumentRepository.uploadDocument(
          mockFile,
          titulo: document.titulo,
          medico: document.medico,
          paciente: document.paciente,
          tipo: document.tipo,
          dataDocumento: document.dataDocumento,
        ),
      ).called(1);
      await tester.disposeWidget();
    });

    testWidgets('it stops on invalid title (empty)', (tester) async {
      // Pump widget and wait for initial document load
      await tester.pumpWidget(view);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // ===== STEP 1: PREVIEW =====
      // Verify we're on preview screen
      expect(find.byKey(const Key('btnConfirm')), findsOneWidget);

      // Tap confirm button to advance to title form
      await tester.tap(find.byKey(const Key('btnConfirm')));
      await tester.pumpAndSettle();

      // ===== STEP 2: TITLE FORM =====
      // Do not fill form and tap next button
      await tester.tap(find.byKey(const Key('btnNext')));
      await tester.pump();

      // Verify error message appears
      expect(find.text('Por favor, insira um título'), findsOneWidget);

      // Verify we're still on title form (metadata form is not visible)
      expect(find.byKey(const Key('inputTitle')), findsOneWidget);
      expect(find.byKey(const Key('inputNomePaciente')), findsNothing);
      await tester.disposeWidget();
    });

    testWidgets('it allows skipping metadata form', (tester) async {
      // Pump widget and wait for initial document load
      await tester.pumpWidget(view);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // ===== STEP 1: PREVIEW =====
      // Tap confirm button
      await tester.tap(find.byKey(const Key('btnConfirm')));
      await tester.pumpAndSettle();

      // ===== STEP 2: TITLE FORM =====
      // Fill in a valid title
      await tester.enterText(
        find.byKey(const Key('inputTitle')),
        document.titulo,
      );
      await tester.pump();

      // Tap next button
      await tester.tap(find.byKey(const Key('btnNext')));
      await tester.pumpAndSettle();

      // ===== STEP 3: METADATA FORM =====
      // Verify we're on metadata form
      expect(find.byKey(const Key('btnSkip')), findsOneWidget);
      expect(find.byKey(const Key('btnSubmit')), findsOneWidget);

      // Tap skip button without filling metadata
      await tester.tap(find.byKey(const Key('btnSkip')));
      await tester.pumpAndSettle();

      // Verify that the upload was initiated with null metadata
      verify(
        () => mockDocumentRepository.uploadDocument(
          mockFile,
          titulo: document.titulo,
          medico: null,
          paciente: null,
          tipo: null,
          dataDocumento: null,
        ),
      ).called(1);
      await tester.disposeWidget();
    });

    testWidgets('it can navigate back from title form to preview', (
      tester,
    ) async {
      // Pump widget and wait for initial document load
      await tester.pumpWidget(view);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // ===== STEP 1: PREVIEW =====
      // Tap confirm button
      await tester.tap(find.byKey(const Key('btnConfirm')));
      await tester.pumpAndSettle();

      // ===== STEP 2: TITLE FORM =====
      // Verify we're on title form
      expect(find.byKey(const Key('inputTitle')), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('btnBack')));
      await tester.pumpAndSettle();

      // ===== VERIFY BACK TO PREVIEW =====
      // Verify we're back on preview screen
      expect(find.byKey(const Key('pdfCarousel')), findsOneWidget);
      expect(find.byKey(const Key('inputTitle')), findsNothing);
      await tester.disposeWidget();
    });

    testWidgets('it can navigate back from metadata form to title form', (
      tester,
    ) async {
      // Pump widget and wait for initial document load
      await tester.pumpWidget(view);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // ===== STEP 1: PREVIEW =====
      // Tap confirm button
      await tester.tap(find.byKey(const Key('btnConfirm')));
      await tester.pumpAndSettle();

      // ===== STEP 2: TITLE FORM =====
      // Fill in a title
      await tester.enterText(find.byKey(const Key('inputTitle')), 'Title');
      await tester.pump();

      // Tap next button
      await tester.tap(find.byKey(const Key('btnNext')));
      await tester.pumpAndSettle();

      // ===== STEP 3: METADATA FORM =====
      // Verify we're on metadata form
      expect(find.byKey(const Key('inputNomePaciente')), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('btnBack')));
      await tester.pumpAndSettle();

      // ===== VERIFY BACK TO TITLE FORM =====
      // Verify we're back on title form
      expect(find.byKey(const Key('inputTitle')), findsOneWidget);
      expect(find.byKey(const Key('inputNomePaciente')), findsNothing);
      await tester.disposeWidget();
    });

    testWidgets('it shows loading indicator on preview initial load', (
      tester,
    ) async {
      // Pump widget
      await tester.pumpWidget(view);

      // Should show loading indicator initially
      expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);

      // Wait for document to load
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Loading indicator should disappear after load
      expect(find.byKey(const Key('loadingIndicator')), findsNothing);
      expect(find.byKey(const Key('pdfCarousel')), findsOneWidget);
      await tester.disposeWidget();
    });
  });
}
