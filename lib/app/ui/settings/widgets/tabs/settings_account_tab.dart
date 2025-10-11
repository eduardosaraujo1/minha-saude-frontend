import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';

class SettingsAccountTab extends StatelessWidget {
  const SettingsAccountTab({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final dialogController = _DialogController(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ações", style: theme.textTheme.titleMedium),
        ...ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Encerrar sessão'),
              onTap: () {
                dialogController.showLogoutDialog(() {
                  viewModel.logout();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              iconColor: colorScheme.error,
              textColor: colorScheme.error,
              title: const Text('Apagar conta'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Conta apagada com sucesso!"),
                  ), //
                );
                dialogController.showDeleteAccountDialog(() {
                  viewModel.requestDeletion();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _DialogController {
  const _DialogController(this.context);

  final BuildContext context;

  void showLogoutDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Encerrar sessão'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm.call();
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteAccountDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
            size: 40,
          ),
          title: Text('Excluir Conta'),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Ao confirmar a exclusão da sua conta, ocorrerá o seguinte:\n\n',
                ),
                TextSpan(
                  text:
                      'Sua conta será imediatamente desativada e não poderá mais ser acessada.\n'
                      'Todos os seus dados, documentos e configurações serão marcados para exclusão permanente.\n'
                      'Você terá até 30 dias para reativar sua conta. Após esse prazo, a exclusão será irreversível.\n'
                      'Para reativar sua conta, entre em contato com nossa equipe de suporte.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm.call();
              },
              child: Text(
                'Excluir Conta',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
