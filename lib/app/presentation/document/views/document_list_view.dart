import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    widget.viewModel.cmdLogout.results.addListener(_onLogoutCommand);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    widget.viewModel.cmdLogout.results.removeListener(_onLogoutCommand);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _onLogoutCommand() {
    final result = widget.viewModel.cmdLogout.results.value;
    if (result.hasData && result.data == true && context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: vm.cmdLogout.results,
              builder: (context, result, _) {
                if (result.isExecuting) {
                  return const CircularProgressIndicator();
                }

                return const Icon(
                  Icons.description,
                  size: 64,
                  color: Colors.blue,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Lista de Documentos', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              'Página ${widget.viewModel.hashCode}',
              style: const TextStyle(color: Colors.grey),
            ),
            FilledButton(
              onPressed: () {
                vm.cmdLogout.execute();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
