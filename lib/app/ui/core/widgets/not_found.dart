import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/session/session_repository.dart';
import '../../../domain/actions/auth/logout_action.dart';
import '../../../routing/routes.dart';

class NotFoundView extends StatelessWidget {
  final String fullPath;

  const NotFoundView(this.fullPath, {super.key});

  @override
  Widget build(BuildContext context) {
    final sessionRepository = GetIt.I<SessionRepository>();
    final logoutAction = GetIt.I<LogoutAction>();

    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 120, color: colorScheme.error),
              const SizedBox(height: 24),
              Text(
                '404',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Página '$fullPath' não encontrada",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A página que você está procurando não existe ou foi movida.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FutureBuilder(
                future: sessionRepository.hasAuthToken(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Column(
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go(Routes.home),
                          icon: const Icon(Icons.home),
                          label: const Text('Ir para início'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            // Clear registration status and auth token
                            await logoutAction.execute();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sair'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return FilledButton.icon(
                      onPressed: () => context.go(Routes.auth),
                      icon: const Icon(Icons.login),
                      label: const Text('Fazer login'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
