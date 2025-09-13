import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';

class DocumentListView extends StatefulWidget {
  const DocumentListView(this.viewModel, {super.key});

  final DocumentListViewModel viewModel;

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Document List View', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Page ${widget.viewModel.hashCode}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
