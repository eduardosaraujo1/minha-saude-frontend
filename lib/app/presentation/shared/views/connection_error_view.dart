import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/managers/app_state_manager.dart';
import 'package:minha_saude_frontend/app/di/get_it.dart';

class ConnectionErrorView extends StatefulWidget {
  const ConnectionErrorView({super.key});

  @override
  State<ConnectionErrorView> createState() => _ConnectionErrorViewState();
}

class _ConnectionErrorViewState extends State<ConnectionErrorView> {
  bool _isRetrying = false;

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      final authRepository = getIt<AuthRepository>();
      final tokenRepository = getIt<TokenRepository>();
      final appStateManager = getIt<AppStateManager>();

      // Force reload cache and check auth status again
      await authRepository.reloadCache();

      // Clear the startup connection error
      appStateManager.clearStartupConnectionError();

      if (mounted) {
        // Navigate based on current auth state
        final hasToken = tokenRepository.hasToken;
        final isRegistered = hasToken ? authRepository.isRegistered : false;

        if (!hasToken) {
          // No token, go to login
          context.go('/login');
        } else if (!isRegistered) {
          // Has token but not registered, go to TOS
          context.go('/tos');
        } else {
          // Fully authenticated, go to home
          context.go('/');
        }
      }
    } catch (e) {
      // Still can't connect, show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ainda não foi possível conectar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Sem conexão',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Não foi possível se comunicar com o servidor',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua conexão com a internet e tente novamente.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _isRetrying ? null : _retryConnection,
                icon: _isRetrying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isRetrying ? 'Tentando...' : 'Tentar novamente'),
                style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isRetrying
                    ? null
                    : () {
                        // Clear the startup connection error and go to login
                        final appStateManager = getIt<AppStateManager>();
                        appStateManager.clearStartupConnectionError();
                        context.go('/login');
                      },
                icon: const Icon(Icons.login),
                label: const Text('Continuar offline'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
