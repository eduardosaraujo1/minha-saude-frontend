import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';

class SettingsGeneralTab extends StatelessWidget {
  const SettingsGeneralTab({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configurações', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Aqui você pode ajustar as configurações do aplicativo.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
