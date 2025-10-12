import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view_models/settings_edit_view_model.dart';

class SettingsEditPhone extends StatefulWidget {
  const SettingsEditPhone({required this.viewModel, super.key});

  final SettingsEditViewModel viewModel;

  @override
  State<SettingsEditPhone> createState() => _SettingsEditPhoneState();
}

class _SettingsEditPhoneState extends State<SettingsEditPhone> {
  late final SettingsEditViewModel viewModel;
  late final _EditPhoneFormController _formController;
  @override
  void initState() {
    _formController = _EditPhoneFormController();
    viewModel = widget.viewModel;
    viewModel.loadCurrentValue.addListener(_onDataLoad);
    viewModel.updatePhoneCommand.addListener(_onUpdate);
    viewModel.loadCurrentValue.execute(null);
    super.initState();
  }

  @override
  void dispose() {
    viewModel.loadCurrentValue.removeListener(_onDataLoad);
    _formController.phoneController.dispose();
    super.dispose();
  }

  void _triggerSave() {
    // If form is valid
    if (_formController.validate()) {
      viewModel.updatePhoneCommand.execute(
        _formController.phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Telefone atualizado com sucesso!")),
      );

      context.pop();
    }
  }

  void _onUpdate() {
    var result = viewModel.updatePhoneCommand.value;
    if (result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao atualizar telefone: ${result.tryGetError()}",
          ),
        ),
      );

      if (context.canPop()) {
        context.pop();
      }
    }

    if (result.isSuccess()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Telefone atualizado com sucesso!")),
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
      _formController.phoneController.text = value;
    }
    if (result != null && result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao carregar telefone. Por favor feche essa página.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Telefone')),
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
                            key: ValueKey('inputPhone'),
                            controller: _formController.phoneController,
                            validator: _formController.validatePhone,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              icon: Icon(Icons.phone),
                            ),
                          ),
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: viewModel.updatePhoneCommand.isExecuting,
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

class _EditPhoneFormController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  bool validate() {
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um telefone.';
    }
    if (value.length < 8) {
      return 'O telefone deve ter pelo menos 8 caracteres.';
    }
    return null;
  }
}
