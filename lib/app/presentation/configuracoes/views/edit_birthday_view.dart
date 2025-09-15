import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/edit_birthday_view_model.dart';
import 'package:watch_it/watch_it.dart';

class EditBirthdayView extends WatchingStatefulWidget {
  final EditBirthdayViewModel viewModel;

  const EditBirthdayView(this.viewModel, {super.key});

  @override
  State<EditBirthdayView> createState() => _EditBirthdayViewState();
}

class _EditBirthdayViewState extends State<EditBirthdayView> {
  EditBirthdayViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        viewModel.updateSelectedDate(selectedDate);
      });
    }
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
        title: const Text('Editar Data de Nascimento'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo Data de Nascimento com DatePicker
            InkWell(
              onTap: isLoading ? null : () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewModel.selectedDate != null
                          ? viewModel.formatDate(viewModel.selectedDate!)
                          : 'Selecione uma data',
                      style: TextStyle(
                        fontSize: 16,
                        color: viewModel.selectedDate != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
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
                    final success = await viewModel.saveBirthDate();
                    if (success && context.mounted) {
                      Navigator.pop(
                        context,
                        viewModel.selectedDate != null
                            ? viewModel.formatDate(viewModel.selectedDate!)
                            : null,
                      );
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
