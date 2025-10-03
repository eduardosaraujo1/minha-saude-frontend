import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/edit_telefone_view_model.dart';
import 'package:watch_it/watch_it.dart';

class EditTelefoneView extends WatchingStatefulWidget {
  final EditTelefoneViewModel viewModel;

  const EditTelefoneView(this.viewModel, {super.key});

  @override
  State<EditTelefoneView> createState() => _EditTelefoneViewState();
}

class _EditTelefoneViewState extends State<EditTelefoneView> {
  EditTelefoneViewModel get viewModel => widget.viewModel;

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
        title: const Text('Editar Telefone'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo Telefone
            TextField(
              controller: viewModel.telefoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                MaskTextInputFormatter(
                  mask: '+## (##) #####-####',
                  filter: {"#": RegExp(r'[0-9]')},
                  type: MaskAutoCompletionType.lazy,
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '+55 11 95149-0211',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                prefixIcon: Icon(Icons.phone),
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
                    final success = await viewModel.saveTelefone();
                    if (success && context.mounted) {
                      Navigator.pop(context, viewModel.telefoneController.text);
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
