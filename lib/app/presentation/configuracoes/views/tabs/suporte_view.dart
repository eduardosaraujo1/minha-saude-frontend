import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuporteView extends StatelessWidget {
  const SuporteView({super.key});

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título Informações
              _buildTitleRow(textTheme),
              // Texto de descrição
              _buildInfoText(textTheme, context),
            ],
          ),
        ),
      ],
    );
  }

  RichText _buildInfoText(TextTheme textTheme, BuildContext context) {
    return RichText(
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
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTitleRow(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Informações',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const _ClipboardButton('tccminhasaude2025@gmail.com'),
      ],
    );
  }
}

class _ClipboardButton extends StatelessWidget {
  final String content;

  const _ClipboardButton(this.content);

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: content));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: IconButton(
        onPressed: () {
          _copyToClipboard();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mail copiado para a área de transferência!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.content_copy, size: 20),
        color: colorScheme.primary,
      ),
    );
  }
}
