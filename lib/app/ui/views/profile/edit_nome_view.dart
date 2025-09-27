import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/edit_nome_view_model.dart';
import 'package:watch_it/watch_it.dart';

class EditNomeView extends WatchingStatefulWidget {
  final EditNomeViewModel viewModel;

  const EditNomeView(this.viewModel, {super.key});

  @override
  State<EditNomeView> createState() => _EditNomeViewState();
}

class _EditNomeViewState extends State<EditNomeView> {
  EditNomeViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = watch(viewModel.isLoading).value;

    registerHandler<ValueNotifier, String?>(
      target: viewModel.errorMessage,
      handler: (context, newValue, _) {
        _onErrorChanged(context, newValue);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Nome'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo Nome
            TextField(
              controller: viewModel.nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Botões Cancelar e Confirmar
            _buildActionButtons(context, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 4,
      children: [
        // Cancelar
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
            ),
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancelar'),
          ),
        ),
        // Confirmar
        Expanded(
          child: FilledButton(
            onPressed: isLoading
                ? null
                : () async {
                    final success = await viewModel.saveNome();
                    if (success && context.mounted) {
                      Navigator.pop(context, viewModel.nomeController.text);
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Confirmar'),
          ),
        ),
      ],
    );
  }

  void _onErrorChanged(BuildContext context, String? newValue) {
    if (newValue != null && newValue.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 10),
          showCloseIcon: true,
        ),
      );
      viewModel.errorMessage.value = null;
    }
  }
}
