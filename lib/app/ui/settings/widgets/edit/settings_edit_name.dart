import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/settings_edit_view_model.dart';

class SettingsEditName extends StatefulWidget {
  const SettingsEditName({required this.viewModel, super.key});

  final SettingsEditViewModel viewModel;

  @override
  State<SettingsEditName> createState() => _SettingsEditNameState();
}

class _SettingsEditNameState extends State<SettingsEditName> {
  late final SettingsEditViewModel viewModel;
  late final _EditNameFormController _formController;
  @override
  void initState() {
    _formController = _EditNameFormController();
    viewModel = widget.viewModel;
    viewModel.loadCurrentValue.addListener(_onDataLoad);
    viewModel.updateNameCommand.addListener(_onUpdate);
    viewModel.loadCurrentValue.execute(null);
    super.initState();
  }

  @override
  void dispose() {
    viewModel.loadCurrentValue.removeListener(_onDataLoad);
    _formController.nameController.dispose();
    super.dispose();
  }

  void _triggerSave() {
    // If form is valid
    if (_formController.validate()) {
      viewModel.updateNameCommand.execute(_formController.nameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nome atualizado com sucesso!")),
      );

      context.pop();
    }
  }

  void _onUpdate() {
    var result = viewModel.updateNameCommand.value;
    if (result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao atualizar nome: ${result.tryGetError()}",
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      }
    }

    if (result.isSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nome atualizado com sucesso!")),
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
      _formController.nameController.text = value;
    }
    if (result != null && result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao carregar nome. Por favor feche essa página.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Nome')),
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
                            key: ValueKey('inputName'),
                            controller: _formController.nameController,
                            validator: _formController.validateName,
                            decoration: InputDecoration(
                              icon: Icon(Icons.person),
                            ),
                          ),
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: viewModel.updateNameCommand.isExecuting,
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

class _EditNameFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  bool validate() {
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome.';
    }
    if (value.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres.';
    }
    return null;
  }
}
