import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../view_models/metadata/document_metadata_view_model.dart';

class DocumentMetadataView extends StatelessWidget {
  const DocumentMetadataView({required this.viewModel, super.key});

  final DocumentMetadataViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Careful: do not put this inside a ListenableBuilder
    // Stateless widgets are never rebuilt, so this will only run once
    viewModel.loadDocument.execute();

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
                error?.toString() ?? "Ocorreu um erro ao carregar o documento.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }

          final docInfo = val.data!.tryGetSuccess()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DocumentInfoCard(
                  label: 'Título',
                  value: _coalesceNullOrEmpty(
                    docInfo.titulo,
                    'Documento sem título',
                  ),
                ),
                _DocumentInfoCard(
                  label: 'Nome do(a) Paciente',
                  value: _coalesceNullOrEmpty(docInfo.paciente, 'N/A'),
                ),
                _DocumentInfoCard(
                  label: 'Nome do(a) Médico(a)',
                  value: _coalesceNullOrEmpty(docInfo.medico, 'N/A'),
                ),
                _DocumentInfoCard(
                  label: 'Tipo de Documento',
                  value: _coalesceNullOrEmpty(docInfo.tipo, 'N/A'),
                ),
                _DocumentInfoCard(
                  label: 'Data do Documento',
                  value: docInfo.dataDocumento == null
                      ? 'N/A'
                      : DateFormat('dd/MM/yyyy').format(docInfo.dataDocumento!),
                ),
                _DocumentInfoCard(
                  label: 'Adicionado em',
                  value: DateFormat('dd/MM/yyyy').format(docInfo.createdAt),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _coalesceNullOrEmpty(String? value, String fallback) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }
}

class _DocumentInfoCard extends StatelessWidget {
  const _DocumentInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
