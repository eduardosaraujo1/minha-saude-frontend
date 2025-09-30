import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/view_models/auth/tos_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/auth/layouts/login_form_layout.dart';
import 'package:minha_saude_frontend/app/ui/widgets/auth/text_scroller.dart';
import 'package:minha_saude_frontend/app/ui/router/routes.dart';

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
            TextScroller(text: viewModel.termos),
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
