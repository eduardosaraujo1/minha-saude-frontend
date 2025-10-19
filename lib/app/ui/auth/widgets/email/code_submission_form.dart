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

  final _SubmissionTimer _submissionTimer = _SubmissionTimer(
    cooldownDuration: const Duration(seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    _submissionTimer.restart();

    // Listen to requestCodeCommand to restart cooldown on successful resend
    viewModel.requestCodeCommand.addListener(_onRequestCodeChanged);
  }

  @override
  void dispose() {
    _submissionTimer.dispose();
    viewModel.requestCodeCommand.removeListener(_onRequestCodeChanged);
    controller.dispose();
    super.dispose();
  }

  void _onRequestCodeChanged() {
    final result = viewModel.requestCodeCommand.value;
    // Only restart cooldown if the request was successful
    if (result != null && result.isSuccess()) {
      _submissionTimer.restart();
    }
  }

  void _submitFormIfValid() {
    if (!controller.validate()) {
      return;
    }

    viewModel.verifyCodeCommand.execute(controller.codeController.text);
  }

  void _resendCode() {
    // Check if we have a valid email from the previous request
    final email = viewModel.requestCodeCommand.value?.tryGetSuccess();

    if (email == null) {
      // Should not happen in normal flow, but handle it gracefully
      return;
    }

    viewModel.requestCodeCommand.execute(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = viewModel.requestCodeCommand.value?.tryGetSuccess() ?? '';

    return LoginFormLayout(
      onBackPressed: () {
        viewModel.stage.value = EmailRoutes.requestCode;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Verificar E-mail', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyLarge,
                  children: [
                    const TextSpan(
                      text:
                          'Digite a seguir o código de verificação enviado ao e-mail ',
                    ),
                    TextSpan(
                      text: email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                key: ValueKey('inputCode'),
                controller: controller.codeController,
                validator: controller.validateCode,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  counterText: '',
                ),
                maxLength: 6,
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Não recebeu?', style: theme.textTheme.bodyMedium),
                  _tryAgainButton(),
                ],
              ),
              _actionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<int> _tryAgainButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder(
      valueListenable: _submissionTimer.remainingSeconds,
      builder: (context, remainingSeconds, child) {
        return ValueListenableBuilder(
          valueListenable: viewModel.requestCodeCommand.isExecuting,
          builder: (context, isExecuting, child) {
            final isOnCooldown = remainingSeconds > 0;
            final email = viewModel.requestCodeCommand.value?.tryGetSuccess();
            final hasError =
                viewModel.requestCodeCommand.value?.isError() ?? false;

            // Disable button if: executing, on cooldown, no email available, or error
            final isDisabled = isExecuting || isOnCooldown || email == null;

            String buttonText;
            if (isExecuting) {
              buttonText = 'Enviando...';
            } else if (isOnCooldown) {
              buttonText = 'Reenviar código (${remainingSeconds}s)';
            } else if (hasError) {
              buttonText = 'Tentar novamente';
            } else {
              buttonText = 'Reenviar código';
            }

            return TextButton(
              key: const ValueKey("btnResendCode"),
              onPressed: isDisabled ? null : _resendCode,
              child: Text(
                buttonText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDisabled
                      ? colorScheme.onSurface.withValues(alpha: 0.38)
                      : colorScheme.primary,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Row _actionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: OutlinedButton(
            key: ValueKey('btnVoltar'),
            onPressed: () {
              viewModel.stage.value = EmailRoutes.requestCode;
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
                            colorScheme.onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                      )
                    : const Text('Verificar e Entrar'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubmissionTimer {
  _SubmissionTimer({required Duration cooldownDuration})
    : _cooldownDuration = cooldownDuration {
    _remainingSeconds = ValueNotifier(_cooldownDuration.inSeconds);
  }

  final Duration _cooldownDuration;
  late final ValueNotifier<int> _remainingSeconds;

  Timer? _resendCooldownTimer;

  ValueNotifier<int> get remainingSeconds => _remainingSeconds;

  void dispose() {
    _resendCooldownTimer?.cancel();
    _remainingSeconds.dispose();
  }

  void restart() {
    _resendCooldownTimer?.cancel();
    _remainingSeconds.value = _cooldownDuration.inSeconds;

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds.value <= 0) {
        timer.cancel();
        return;
      }

      _remainingSeconds.value--;
    });
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
