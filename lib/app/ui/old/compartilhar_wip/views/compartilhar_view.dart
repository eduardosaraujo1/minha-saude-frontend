import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';

class CompartilharView extends StatelessWidget {
  const CompartilharView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Compartilhar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Códigos de Compartilhamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
