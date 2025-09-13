import 'package:flutter/material.dart';

class LixeiraView extends StatelessWidget {
  const LixeiraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lixeira')),
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
