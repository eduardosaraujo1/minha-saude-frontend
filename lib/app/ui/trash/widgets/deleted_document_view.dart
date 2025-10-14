import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';

import '../view_models/deleted_document_view_model.dart';

class DeletedDocumentView extends StatefulWidget {
  const DeletedDocumentView({required this.viewModelFactory, super.key});

  final DeletedDocumentViewModel Function() viewModelFactory;

  @override
  State<DeletedDocumentView> createState() => _DeletedDocumentViewState();
}

class _DeletedDocumentViewState extends State<DeletedDocumentView> {
  late final DeletedDocumentViewModel viewModel = widget.viewModelFactory();
  @override
  void initState() {
    super.initState();

    viewModel.loadDocument.addListener(_onLoadUpdate);
    viewModel.deleteDocumentForever.addListener(_onDeleteUpdate);
    viewModel.restoreDocument.addListener(_onRestoreUpdate);
    viewModel.loadDocument.execute();
  }

  @override
  void dispose() {
    viewModel.loadDocument.removeListener(_onLoadUpdate);
    viewModel.deleteDocumentForever.removeListener(_onDeleteUpdate);
    viewModel.restoreDocument.removeListener(_onRestoreUpdate);
    viewModel.dispose();

    super.dispose();
  }

  void _onRestoreUpdate() {
    if (!mounted) return;

    final state = viewModel.restoreDocument.value;

    if (state == null) {
      return;
    }

    if (state.isSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento restaurado com sucesso.')),
      );

      context.pop();
    } else if (state.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao restaurar o documento.')),
      );
    }
  }

  void _onDeleteUpdate() {
    if (!mounted) return;

    final state = viewModel.deleteDocumentForever.value;

    if (state == null) {
      return;
    }

    if (state.isSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento excluído permanentemente.')),
      );

      context.pop();
    } else if (state.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao excluir o documento.')),
      );
    }
  }

  void _onLoadUpdate() {
    if (!mounted) return;

    final state = viewModel.loadDocument.value;

    if (state == null) {
      return;
    }

    if (state.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao carregar o documento. ')),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do documento')),
      body: ValueListenableBuilder(
        valueListenable: viewModel.loadDocument.results,
        builder: (context, loadResult, child) {
          final isLoading = loadResult.isExecuting;
          final documentResult = loadResult.data;
          final isError = documentResult?.isError() ?? false;

          if (isLoading || documentResult == null || isError) {
            return const Center(child: CircularProgressIndicator());
          }

          final document = documentResult.tryGetSuccess()!;
          final userInfo = _makeUserInfoFields(document);

          return SizedBox.expand(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Informações', style: theme.textTheme.titleMedium),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: userInfo.length,
                    itemBuilder: (context, i) {
                      return userInfo[i];
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Ações', style: theme.textTheme.titleMedium),
                  ValueListenableBuilder(
                    valueListenable:
                        viewModel.deleteDocumentForever.isExecuting,
                    builder: (context, deleteIsExecuting, child) {
                      return ValueListenableBuilder(
                        valueListenable: viewModel.restoreDocument.isExecuting,
                        builder: (context, restoreIsExecuting, child) {
                          final isLoading =
                              deleteIsExecuting || restoreIsExecuting;
                          return Opacity(
                            opacity: isLoading ? 0.5 : 1.0,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.restore),
                                  title: Text('Restaurar'),
                                  onTap: isLoading
                                      ? null
                                      : () => _showRestoreConfirmationDialog(),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete_forever,
                                    color: colorScheme.error,
                                  ),
                                  title: Text(
                                    'Excluir permanentemente',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                  onTap: isLoading
                                      ? null
                                      : () => _showDeleteConfirmationDialog(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _makeUserInfoFields(Document document) {
    return [
      _UserInfoCard(
        label: 'Nome do(a) Paciente',
        value: _coalesceNullOrEmpty(document.paciente, 'Indefinido'),
      ),
      _UserInfoCard(
        label: 'Nome do(a) Médico(a)',
        value: _coalesceNullOrEmpty(document.medico, 'Indefinido'),
      ),
      _UserInfoCard(
        label: 'Tipo de Documento',
        value: _coalesceNullOrEmpty(document.tipo, 'Indefinido'),
      ),
      _UserInfoCard(
        label: 'Data do Documento',
        value: document.dataDocumento == null
            ? 'Indefinida'
            : _formatDate(document.dataDocumento!),
      ),
      if (document.deletedAt != null)
        _UserInfoCard(
          label: 'Excluído em',
          value: _formatDate(document.deletedAt!),
        ),
    ];
  }

  void _showRestoreConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _RestoreConfirmationDialog(
          onConfirm: () {
            viewModel.restoreDocument.execute();
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DeleteConfirmationDialog(
          onConfirm: () {
            viewModel.deleteDocumentForever.execute();
          },
        );
      },
    );
  }

  String _formatDate(DateTime dataDocumento) {
    return DateFormat('dd/MM/yyyy').format(dataDocumento);
  }

  String _coalesceNullOrEmpty(String? value, String fallback) {
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }
}

class _RestoreConfirmationDialog extends StatelessWidget {
  const _RestoreConfirmationDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Restaurar documento'),
      content: const Text(
        'Tem certeza de que deseja restaurar este documento?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: FilledButton.styleFrom(),
          child: const Text('Restaurar'),
        ),
      ],
    );
  }
}

class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: const Text(
        'Tem certeza de que deseja excluir este documento permanentemente? Esta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
