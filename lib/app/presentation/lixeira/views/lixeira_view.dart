import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/brand_app_bar.dart';

class LixeiraView extends StatelessWidget {
  const LixeiraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Lixeira')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Lixeira', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Documentos excluídos', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
