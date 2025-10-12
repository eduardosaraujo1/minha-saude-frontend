import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../view_models/settings_edit_view_model.dart';

class SettingsEditBirthdate extends StatefulWidget {
  const SettingsEditBirthdate({required this.viewModel, super.key});

  final SettingsEditViewModel viewModel;

  @override
  State<SettingsEditBirthdate> createState() => _SettingsEditBirthdateState();
}

class _SettingsEditBirthdateState extends State<SettingsEditBirthdate> {
  late final SettingsEditViewModel viewModel;
  late final _EditBirthdateFormController _formController;
  @override
  void initState() {
    _formController = _EditBirthdateFormController();
    viewModel = widget.viewModel;
    viewModel.loadCurrentValue.addListener(_onDataLoad);
    viewModel.updateBirthdateCommand.addListener(_onUpdate);
    viewModel.loadCurrentValue.execute(null);
    super.initState();
  }

  @override
  void dispose() {
    viewModel.loadCurrentValue.removeListener(_onDataLoad);
    _formController.birthdateController.dispose();
    super.dispose();
  }

  void _triggerSave() {
    // If form is valid
    if (_formController.validate()) {
      final date = DateFormat(
        "dd/MM/yyyy",
      ).tryParse(_formController.birthdateController.text);
      if (date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Ocorreu um erro ao interpretar a data. Formato correto: DD/MM/AAAA.",
            ),
          ),
        );
        return;
      }

      viewModel.updateBirthdateCommand.execute(date);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data de nascimento atualizada com sucesso!"),
        ),
      );

      context.pop();
    }
  }

  void _onUpdate() {
    var result = viewModel.updateBirthdateCommand.value;
    if (result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao atualizar data de nascimento: ${result.tryGetError()}",
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      }
    }

    if (result.isSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data de nascimento atualizada com sucesso!"),
        ),
      );

      if (context.canPop()) {
        context.pop();
      }
    }
  }

  void _onDataLoad() {
    var result = viewModel.loadCurrentValue.value;
    final value = result?.tryGetSuccess();
    if (value != null) {
      _formController.birthdateController.text = value;
    }
    if (result != null && result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao carregar data de nascimento. Por favor feche essa página.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Data de Nascimento')),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: AlwaysScrollableScrollPhysics(),
          child: ValueListenableBuilder(
            valueListenable: viewModel.loadCurrentValue.isExecuting,
            builder: (context, isLoading, child) {
              final fieldValue = viewModel.loadCurrentValue.value
                  ?.tryGetSuccess();
              return Column(
                children: [
                  Form(
                    key: _formController.formKey,
                    child: isLoading || fieldValue == null
                        ? CircularProgressIndicator()
                        : TextFormField(
                            key: ValueKey('inputBirthdate'),
                            controller: _formController.birthdateController,
                            validator: _formController.validateBirthdate,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              hintText: 'DD/MM/AAAA',
                            ),
                          ),
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable:
                        viewModel.updateBirthdateCommand.isExecuting,
                    builder: (context, isRunning, child) {
                      return isRunning
                          ? CircularProgressIndicator()
                          : Row(
                              spacing: 4,
                              children: [
                                Expanded(
                                  child: FilledButton.tonal(
                                    key: ValueKey('btnCancel'),
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: const Text("Cancelar"),
                                  ),
                                ),
                                Expanded(
                                  child: FilledButton(
                                    key: ValueKey('btnSave'),
                                    onPressed: fieldValue == null
                                        ? null
                                        : _triggerSave,
                                    child: const Text("Salvar"),
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditBirthdateFormController {
  final formKey = GlobalKey<FormState>();
  final birthdateController = TextEditingController();

  bool validate() {
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }

  String? validateBirthdate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma data de nascimento.';
    }
    // Basic date format validation (DD/MM/YYYY)
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Use o formato DD/MM/AAAA.';
    }
    return null;
  }
}
