part of 'register_navigator.dart';

class RegisterTos extends StatelessWidget {
  const RegisterTos({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: ValueListenableBuilder(
          valueListenable: viewModel.loadTosCommand,
          builder: (context, value, child) {
            if (value?.isError() ?? false) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao carregar os Termos de Serviço.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Por favor, tente novamente mais tarde ou entre em contato com o suporte.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final tos = value?.tryGetSuccess();

            return Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Termos e Condições', style: theme.textTheme.titleLarge),
                tos == null
                    ? Center(child: CircularProgressIndicator())
                    : MarkdownTextScroller(text: tos),
                FilledButton(
                  key: const ValueKey('btnAcceptTos'),
                  onPressed: () {
                    // Use local RouterNavigator to go to Register Form
                    Navigator.of(context).pushNamed(_RegisterRoutes.form);
                  },
                  child: Text('Li e concordo com os termos'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
