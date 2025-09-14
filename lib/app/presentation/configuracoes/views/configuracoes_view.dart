import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';

class ConfiguracoesView extends StatelessWidget {
  const ConfiguracoesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Configurações')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Configurações', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              'Configurações do aplicativo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
