part of 'email_auth_view.dart';

class CodeRequestForm extends StatelessWidget {
  const CodeRequestForm({required this.viewModel, super.key});

  final EmailAuthViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = CodeRequestFormController();

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
              Text('Digite seu E-mail', style: theme.textTheme.titleLarge),
              Text(
                'Digite o E-mail com o qual você deseja se registrar',
                style: theme.textTheme.bodyLarge,
              ),
              TextFormField(
                key: ValueKey('inputEmail'),
                controller: controller.emailController,
                validator: controller.validateEmail,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              ValueListenableBuilder(
                valueListenable: viewModel.requestCodeCommand.isExecuting,
                builder: (context, isExecuting, child) {
                  return FilledButton(
                    key: ValueKey('btnRequestCode'),
                    onPressed: isExecuting
                        ? null
                        : () {
                            if (controller.validate()) {
                              viewModel.requestCodeCommand.execute(
                                controller.emailController.text,
                              );
                            }
                          },
                    child: isExecuting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onSurface.withValues(alpha: 0.38),
                              ),
                            ),
                          )
                        : const Text('Continuar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CodeRequestFormController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  /// Validates the form and returns true if valid
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }

    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }

    return null;
  }

  void dispose() {
    emailController.dispose();
  }
}
