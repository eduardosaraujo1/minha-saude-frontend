import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_state_view_model.dart';
import 'package:pdfx/pdfx.dart';
import 'package:watch_it/watch_it.dart';

class DocumentScanView extends WatchingStatefulWidget {
  final DocumentScanViewModel viewModel;
  const DocumentScanView(this.viewModel, {super.key});

  @override
  State<DocumentScanView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DocumentScanView> {
  DocumentScanViewModel get viewModel => widget.viewModel;
  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = watch(viewModel.status).value;

    registerHandler<ValueNotifier, String?>(
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue);
      },
      target: viewModel.errorMessage,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Documento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Builder(
        builder: (context) {
          if (status == PageStatus.error &&
              viewModel.errorMessage.value != null) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    'Ocorreu um erro desconhecido. Por favor, tente novamente.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () {
                      context.pop();
                    },
                    child: Text("Voltar"),
                  ),
                ],
              ),
            );
          } else if (status == PageStatus.loaded &&
              viewModel.pdfController != null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [_buildPreview(), _buildBottomCard()]),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildPreview() {
    if (viewModel.pdfController == null) {
      return const Center(child: Text('Nenhum documento carregado.'));
    }
    return Expanded(
      child: PdfView(
        controller: viewModel.pdfController!,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: BouncingScrollPhysics(),
        onDocumentError: (error) {
          viewModel.errorMessage.value = 'Erro ao carregar documento: $error';
        },
      ),
    );
  }

  Widget _buildBottomCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Este documento parece certo?',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer,
                  ),
                  label: const Text('Cancelar'),
                  icon: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    context.go('/documentos/create');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
