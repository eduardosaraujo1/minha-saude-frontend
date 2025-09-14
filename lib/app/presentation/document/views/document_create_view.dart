import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_create_view_model.dart';
import 'package:watch_it/watch_it.dart';

class DocumentCreateView extends WatchingStatefulWidget {
  final DocumentCreateViewModel viewModel;
  const DocumentCreateView(this.viewModel, {super.key});

  @override
  State<DocumentCreateView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DocumentCreateView> {
  DocumentCreateViewModel get viewModel => widget.viewModel;
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
    final isLoading = watch(viewModel.isLoading).value;

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
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage.value != null) {
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
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tela de criação de documento'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.isLoading.value = true;
                      // Simulate a network request
                      Future.delayed(const Duration(seconds: 2), () {
                        viewModel.isLoading.value = false;
                        viewModel.errorMessage.value =
                            'Erro ao criar documento';
                      });
                    },
                    child: const Text('Criar Documento'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
