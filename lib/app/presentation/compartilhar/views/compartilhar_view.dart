import 'package:flutter/material.dart';

class CompartilharView extends StatelessWidget {
  const CompartilharView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhar')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Compartilhar Documentos', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              'Funcionalidade de compartilhamento',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
