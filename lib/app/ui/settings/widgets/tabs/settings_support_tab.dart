import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';

class SettingsSupportTab extends StatelessWidget {
  const SettingsSupportTab({super.key, required this.viewModel});
  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título Informações
        Text(
          'Informações',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),

        // Texto de descrição
        RichText(
          text: TextSpan(
            style: textTheme.bodyMedium,
            children: [
              const TextSpan(
                text:
                    'Em caso de dúvidas, sugestões ou problemas, você pode entrar em contato conosco através do e-mail: ',
              ),
              TextSpan(
                text: 'tccminhasaude2025@gmail.com',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonal(
          onPressed: () {
            try {
              Clipboard.setData(
                ClipboardData(text: 'tccminhasaude2025@gmail.com'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copiado com sucesso!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } on Exception {
              // Falha ao copiar para a área de transferência
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Falha ao copiar o e-mail. Tente novamente.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text('Copiar E-mail'),
        ),
      ],
    );
  }
}
