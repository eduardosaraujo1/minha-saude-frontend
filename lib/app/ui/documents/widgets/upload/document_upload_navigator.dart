import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../utils/format.dart';
import '../../view_models/upload/document_upload_view_model.dart';

part 'steps/metadata_form.dart';
part 'steps/title_form.dart';
part 'steps/upload_preview.dart';

class DocumentUploadNavigator extends StatefulWidget {
  const DocumentUploadNavigator({required this.viewModelFactory, super.key});
  final DocumentUploadViewModel Function() viewModelFactory;

  @override
  State<DocumentUploadNavigator> createState() =>
      _DocumentUploadNavigatorState();
}

class _DocumentUploadNavigatorState extends State<DocumentUploadNavigator> {
  late final DocumentUploadViewModel viewModel = widget.viewModelFactory();

  @override
  void initState() {
    super.initState();

    viewModel.getDocumentCommand.addListener(_onGetDocument);
    viewModel.uploadDocument.addListener(_onUploadDocument);
  }

  @override
  void dispose() {
    viewModel.getDocumentCommand.removeListener(_onGetDocument);
    viewModel.uploadDocument.removeListener(_onUploadDocument);
    viewModel.dispose();

    super.dispose();
  }

  void _onGetDocument() {
    final result = viewModel.getDocumentCommand.value;

    if (!mounted || result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Operação cancelada.')));

      context.go(Routes.documentos);
      return;
    }
  }

  void _onUploadDocument() {
    if (!mounted || viewModel.uploadDocument.value == null) return;

    final result = viewModel.uploadDocument.value!;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro ao enviar o documento. Tente novamente mais tarde.',
          ),
        ),
      );
    }

    if (result.isSuccess()) {
      context.go(
        Routes.documentos,
        extra: SnackBar(content: Text('Documento enviado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        var currentStepIndex = viewModel.currentStep.value.index;
        if (currentStepIndex <= 0) {
          context.go(Routes.documentos);
          return;
        }

        viewModel.currentStep.value = UploadStep.values[currentStepIndex - 1];
      },
      child: ValueListenableBuilder(
        valueListenable: viewModel.currentStep,
        builder: (context, value, child) {
          return IndexedStack(
            index: value.index,
            children: [
              UploadPreview(viewModel: viewModel),
              TitleForm(viewModel: viewModel),
              MetadataForm(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}
