import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';

class SelecionarDocumentosView extends StatefulWidget {
  const SelecionarDocumentosView({super.key});

  @override
  State<SelecionarDocumentosView> createState() =>
      _SelecionarDocumentosViewState();
}

class _SelecionarDocumentosViewState extends State<SelecionarDocumentosView> {
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
