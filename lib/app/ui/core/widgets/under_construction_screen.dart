import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/core/widgets/brand_app_bar.dart';

class UnderConstructionScreen extends StatelessWidget {
  const UnderConstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: BrandAppBar(title: const Text('Em desenvolvmento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.construction, size: 100, color: colorScheme.secondary),
            Text(
              'Estamos trabalhando para trazer essa funcionalidade em breve!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
