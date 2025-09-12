import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/tos_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/layouts/login_form_layout.dart';
import 'package:minha_saude_frontend/app/presentation/auth/widgets/text_scroller.dart';

class TosView extends StatelessWidget {
  final TosViewModel viewModel;

  const TosView(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Termos e Condições', style: theme.textTheme.titleLarge),
            TextScroller(text: viewModel.termos),
            FilledButton(
              onPressed: () {
                context.push("/register");
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text('Li e concordo com os termos'),
            ),
          ],
        ),
      ),
    );
  }
}
