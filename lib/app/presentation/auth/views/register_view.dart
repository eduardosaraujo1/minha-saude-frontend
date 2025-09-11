import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/layouts/login_form_layout.dart';

class RegisterView extends StatefulWidget {
  final RegisterViewModel viewModel;
  const RegisterView(this.viewModel, {super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                'Vamos concluir seu cadastro',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Por favor, preencha os campos abaixo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextFormField(
                controller: vm.nomeController,
                validator: vm.validateNome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: vm.cpfController,
                validator: vm.validateCpf,
                decoration: InputDecoration(
                  hint: Text(
                    "123.456.789-10",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(0xAA),
                    ),
                  ),
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '###.###.###-##',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              TextFormField(
                controller: vm.dataNascimentoController,
                validator: vm.validateDtNascimento,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: () => _triggerBirthDatePicker(context),
              ),
              TextFormField(
                controller: vm.telefoneController,
                validator: vm.validateTelefone,
                decoration: InputDecoration(
                  hint: Text(
                    "+55 11 98765-4321",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(0xAA),
                    ),
                  ),
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '+## (##) #####-####',
                    filter: {"#": RegExp(r'[0-9]')},
                    type: MaskAutoCompletionType.lazy,
                  ),
                ],
              ),
              FilledButton(
                onPressed: () {
                  vm.registerUser();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Confirmar cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerBirthDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      widget.viewModel.dataNascimentoController.value = TextEditingValue(
        text: "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }
}
