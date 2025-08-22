import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/terms_conditions_view_model.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/layouts/login_form_layout.dart';

class TermsConditions extends StatelessWidget {
  final TermsConditionsViewModel viewModel;

  const TermsConditions({required this.viewModel, super.key});

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

class TextScroller extends StatelessWidget {
  const TextScroller({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
