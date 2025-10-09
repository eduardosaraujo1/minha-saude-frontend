import 'package:flutter/material.dart';

import '../../view_models/metadata/document_metadata_view_model.dart';

class DocumentMetadataView extends StatelessWidget {
  const DocumentMetadataView({required this.viewModel, super.key});

  final DocumentMetadataViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Informações do documento"), //
        backgroundColor: colorScheme.surfaceContainer,
      ),
      body: ValueListenableBuilder(
        valueListenable: viewModel.loadDocument.results,
        builder: (context, val, child) {
          if (val.isExecuting || !val.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (val.data!.isError()) {
            final error = val.data!.tryGetError();

            return Center(
              child: Text(
                error?.toString() ?? "Erro desconhecido",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }

          return Placeholder();
        },
      ),
    );
  }
}
