import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';

class CompartilharView extends StatelessWidget {
  const CompartilharView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Compartilhar')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Códigos de Compartilhamento',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
