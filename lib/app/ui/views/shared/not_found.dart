import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository.dart';
import 'package:minha_saude_frontend/di/service_locator.dart';

class NotFoundView extends StatelessWidget {
  final String fullPath;

  const NotFoundView(this.fullPath, {super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = ServiceLocator.I<AuthRepository>();
    final tokenRepository = ServiceLocator.I<TokenRepository>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 120,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Página '$fullPath' não encontrada",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A página que você está procurando não existe ou foi movida.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FutureBuilder(
                future: tokenRepository.hasToken(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Column(
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.home),
                          label: const Text('Ir para início'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(200, 48),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            // Clear token from storage
                            await tokenRepository.removeToken();
                            // Clear registration status
                            await authRepository.signOut();
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
                      onPressed: () => context.go('/login'),
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
