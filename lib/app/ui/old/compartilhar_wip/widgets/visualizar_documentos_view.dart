import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';

class VisualizarDocumentosView extends StatefulWidget {
  const VisualizarDocumentosView({super.key});

  @override
  State<VisualizarDocumentosView> createState() =>
      _VisualizarDocumentosViewState();
}

class _VisualizarDocumentosViewState extends State<VisualizarDocumentosView> {
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
