import 'package:flutter/material.dart';

import '../../core/widgets/brand_app_bar.dart';
import '../view_models/trash_index_view_model.dart';

class TrashIndexView extends StatelessWidget {
  const TrashIndexView({required this.viewModel, super.key});

  final TrashIndexViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Lixeira')),
      body: const Center(child: Text('Em desenvolvimento')),
    );
  }
}
