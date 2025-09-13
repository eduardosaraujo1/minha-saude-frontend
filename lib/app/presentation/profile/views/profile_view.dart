import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Perfil do Usuário', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Informações do perfil', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
