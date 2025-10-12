import 'package:flutter/material.dart';

import '../view_models/deleted_document_view_model.dart';

class DeletedDocumentView extends StatelessWidget {
  const DeletedDocumentView({required this.viewModel, super.key});

  final DeletedDocumentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documento Excluído')),
      body: const Center(child: Text('Em desenvolvimento')),
    );
  }
}
