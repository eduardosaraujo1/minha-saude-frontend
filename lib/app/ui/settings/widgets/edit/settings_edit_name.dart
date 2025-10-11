import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsEditName extends StatelessWidget {
  const SettingsEditName({super.key});

  void triggerSave() {
    // Implement save logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Nome')),
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              TextField(
                key: ValueKey('inputName'),
                readOnly: true,
                decoration: InputDecoration(icon: Icon(Icons.person)),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      key: ValueKey('btnCancel'),
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text("Cancelar"),
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('btnSave'),
                      onPressed: triggerSave,
                      child: const Text("Salvar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
