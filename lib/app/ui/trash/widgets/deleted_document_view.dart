import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../view_models/deleted_document_view_model.dart';

class DeletedDocumentView extends StatelessWidget {
  const DeletedDocumentView({required this.viewModel, super.key});

  final DeletedDocumentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do documento')),
      body: ValueListenableBuilder(
        valueListenable: ValueNotifier(
          false,
        ), // TODO: link to viewModel properties
        builder: (context, isLoading, child) {
          final errorMessage = null; // TODO: link to viewModel properties
          return isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              :
                // false
                // ? _buildDocumentDetails(context)
                // :
                const Center(child: Text('Documento não encontrado'));
        },
      ),
    );
  }

  // Widget _buildDocumentDetails(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final document = widget.viewModel.document!;

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         // Heading "Informações"
  //         Text('Informações', style: theme.textTheme.titleMedium),
  //         const SizedBox(height: 4),

  //         // Document information cards
  //         _buildInfoCard(context, 'Nome do(a) Paciente', document.paciente),
  //         _buildInfoCard(context, 'Nome do(a) Médico(a)', document.medico),
  //         _buildInfoCard(context, 'Tipo de Documento', document.tipo),
  //         _buildInfoCard(
  //           context,
  //           'Data do Documento',
  //           _formatDate(document.dataDocumento),
  //         ),

  //         if (document.deletedAt != null)
  //           _buildInfoCard(
  //             context,
  //             'Excluído em',
  //             _formatDate(document.deletedAt!),
  //           ),

  //         const SizedBox(height: 8),

  //         // Action buttons section
  //         Text('Ações', style: theme.textTheme.titleMedium),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: FilledButton.icon(
  //                 onPressed: () => _showDeleteConfirmationDialog(context),
  //                 icon: const Icon(Icons.delete_forever),
  //                 label: const Text('Excluir'),
  //                 style: FilledButton.styleFrom(
  //                   backgroundColor: theme.colorScheme.error,
  //                   foregroundColor: theme.colorScheme.onError,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 4),
  //             Expanded(
  //               child: FilledButton.icon(
  //                 onPressed: () => widget.viewModel.restoreDocument(),
  //                 icon: const Icon(Icons.restore),
  //                 label: const Text('Restaurar'),
  //                 style: FilledButton.styleFrom(
  //                   backgroundColor: theme.colorScheme.primary,
  //                   foregroundColor: theme.colorScheme.onPrimary,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildInfoCard(BuildContext context, String label, String value) {
  //   final theme = Theme.of(context);

  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 4.0),
  //     elevation: 0,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(8),
  //       side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             label,
  //             style: theme.textTheme.labelLarge?.copyWith(
  //               color: theme.colorScheme.onSurfaceVariant,
  //             ),
  //           ),
  //           const SizedBox(height: 2),
  //           Text(
  //             value,
  //             style: theme.textTheme.bodyLarge?.copyWith(
  //               color: theme.colorScheme.onSurface,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showDeleteConfirmationDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       final theme = Theme.of(context);
  //       return AlertDialog(
  //         title: const Text('Confirmar exclusão'),
  //         content: const Text(
  //           'Tem certeza de que deseja excluir este documento permanentemente? Esta ação não pode ser desfeita.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             style: TextButton.styleFrom(
  //               foregroundColor: theme.colorScheme.onSurfaceVariant,
  //             ),
  //             child: const Text('Cancelar'),
  //           ),
  //           FilledButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               widget.viewModel.deleteDocumentPermanently();
  //             },
  //             style: FilledButton.styleFrom(
  //               backgroundColor: theme.colorScheme.error,
  //               foregroundColor: theme.colorScheme.onError,
  //             ),
  //             child: const Text('Excluir'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
