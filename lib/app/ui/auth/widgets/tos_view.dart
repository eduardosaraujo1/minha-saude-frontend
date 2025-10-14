import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/routes.dart';
import '../../core/widgets/markdown_text_scroller.dart';
import '../view_models/tos_view_model.dart';
import 'layouts/login_form_layout.dart';

class TosView extends StatelessWidget {
  final TosViewModel viewModel;

  const TosView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Termos e Condições',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            MarkdownTextScroller(text: viewModel.termos),
            FilledButton(
              onPressed: () {
                context.go(Routes.register);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text('Li e concordo com os termos'),
            ),
          ],
        ),
      ),
    );
  }
}
