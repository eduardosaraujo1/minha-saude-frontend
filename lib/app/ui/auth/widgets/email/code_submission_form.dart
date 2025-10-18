part of 'email_auth_view.dart';

class CodeSubmissionForm extends StatefulWidget {
  const CodeSubmissionForm({required this.viewModel, super.key});

  final EmailAuthViewModel viewModel;

  @override
  State<CodeSubmissionForm> createState() => _CodeSubmissionFormState();
}

class _CodeSubmissionFormState extends State<CodeSubmissionForm> {
  EmailAuthViewModel get viewModel => widget.viewModel;
  final CodeSubmissionFormController controller =
      CodeSubmissionFormController();

  void _submitFormIfValid() {
    if (!controller.validate()) {
      return;
    }

    viewModel.verifyCodeCommand.execute(controller.codeController.text);
  }

  void _resendCode() {
    final email = viewModel.requestCodeCommand.value?.tryGetSuccess();
    if (email != null) {
      viewModel.requestCodeCommand.execute(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final email = viewModel.requestCodeCommand.value?.tryGetSuccess() ?? '';

    return LoginFormLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('Verificar E-mail', style: theme.textTheme.titleLarge),
              Text(
                'Digite a seguir o código de verificação enviado ao e-mail $email',
                style: theme.textTheme.bodyLarge,
              ),
              TextFormField(
                key: ValueKey('inputCode'),
                controller: controller.codeController,
                validator: controller.validateCode,
                decoration: const InputDecoration(labelText: 'Código'),
                maxLength: 6,
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Não recebeu? ', style: theme.textTheme.bodyMedium),
                  ValueListenableBuilder(
                    valueListenable: viewModel.requestCodeCommand.isExecuting,
                    builder: (context, isExecuting, child) {
                      return TextButton(
                        key: const ValueKey("btnResendCode"),
                        onPressed: isExecuting ? null : _resendCode,
                        child: Text(
                          'Reenviar código',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isExecuting
                                ? colorScheme.onSurface.withValues(alpha: 0.38)
                                : colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ValueKey('btnVoltar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Voltar'),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: viewModel.verifyCodeCommand.isExecuting,
                      builder: (context, isExecuting, child) {
                        return FilledButton(
                          key: ValueKey('btnConfirmCode'),
                          onPressed: isExecuting ? null : _submitFormIfValid,
                          child: isExecuting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onSurface.withValues(
                                        alpha: 0.38,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text('Verificar e Entrar'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CodeSubmissionFormController {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o código de verificação';
    }

    if (value.length != 6) {
      return 'O código deve ter 6 caracteres';
    }

    return null;
  }

  void dispose() {
    codeController.dispose();
  }
}
