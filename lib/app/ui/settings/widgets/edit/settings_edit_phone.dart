import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../view_models/settings_edit_view_model.dart';

class SettingsEditPhone extends StatefulWidget {
  const SettingsEditPhone({required this.viewModelFactory, super.key});

  final SettingsEditViewModel Function() viewModelFactory;

  @override
  State<SettingsEditPhone> createState() => _SettingsEditPhoneState();
}

class _SettingsEditPhoneState extends State<SettingsEditPhone> {
  late final SettingsEditViewModel viewModel = widget.viewModelFactory();
  late final _EditPhoneFormController _formController;

  @override
  void initState() {
    _formController = _EditPhoneFormController();
    viewModel.loadCurrentValue.addListener(_onDataLoad);
    viewModel.updatePhoneCommand.addListener(_onUpdate);
    viewModel.loadCurrentValue.execute();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.loadCurrentValue.removeListener(_onDataLoad);
    viewModel.loadCurrentValue.removeListener(_onUpdate);
    _formController.phoneController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _triggerSave() {
    // If form is valid
    if (_formController.validate()) {
      viewModel.updatePhoneCommand.execute(
        _formController.phoneController.text,
      );
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
        return;
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
      _formController.phoneController.text = _applyPhoneMask(value)!;
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

  String? _applyPhoneMask(String? phone) {
    if (phone == null) return null;
    if (phone.isEmpty) return null;

    // Remove non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return phone; // Not enough digits to format

    // Apply format (##) #####-####
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6, 10)}';
    } else if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    } else {
      return phone; // Unexpected length, return original
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

              if (isLoading || fieldValue == null) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Form(
                    key: _formController.formKey,
                    child: TextFormField(
                      key: ValueKey('inputPhone'),
                      controller: _formController.phoneController,
                      validator: _formController.validatePhone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        MaskTextInputFormatter(
                          mask: '(##) #####-####',
                          filter: {"#": RegExp(r'[0-9]')},
                          type: MaskAutoCompletionType.lazy,
                        ),
                      ],
                      decoration: InputDecoration(icon: Icon(Icons.phone)),
                    ),
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: viewModel.updatePhoneCommand.isExecuting,
                    builder: (context, isRunning, child) {
                      if (isRunning) {
                        return CircularProgressIndicator();
                      }

                      return Row(
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
                              onPressed: _triggerSave,
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

    // Verifica se o telefone segue o formato brasileiro
    final regex = RegExp(r'^\(\d{2}\) (\d{5})-\d{4}$');
    if (!regex.hasMatch(value)) {
      return 'Telefone deve estar no formato (XX) XXXXX-XXXX';
    }

    return null;
  }
}
