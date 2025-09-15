import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/lixeira/view_models/lixeira_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/document/document_grid.dart';
import 'package:watch_it/watch_it.dart';

class LixeiraView extends WatchingStatefulWidget {
  final LixeiraViewModel viewModel;
  const LixeiraView(this.viewModel, {super.key});

  @override
  State<LixeiraView> createState() => _LixeiraViewState();
}

class _LixeiraViewState extends State<LixeiraView> {
  LixeiraViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final isLoading = watch(viewModel.isLoading).value;
    final errorMessage = watch(viewModel.errorMessage).value;

    registerHandler<ValueNotifier, String?>(
      target: viewModel.errorMessage,
      handler: (context, newValue, cancel) {
        _onErrorChanged(context, newValue);
      },
    );

    return Scaffold(
      appBar: BrandAppBar(title: const Text('Lixeira')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Heading written "Lixeira" in titleLarge style from theme
            Text('Lixeira', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Content based on state
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : viewModel.deletedDocuments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum documento excluído',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : _buildDeletedDocumentsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedDocumentsGrid() {
    return DocumentGrid(
      documents: viewModel.deletedDocuments,
      onDocumentTap: (document) {
        context.go('/lixeira/${document.id}');
      },
    );
  }

  void _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null && newValue.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      viewModel.clearErrorMessage();
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
