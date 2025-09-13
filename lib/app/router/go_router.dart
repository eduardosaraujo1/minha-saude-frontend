import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/di/get_it.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/tos_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/login_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/register_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/tos_view.dart';
import 'package:minha_saude_frontend/app/presentation/compartilhar/views/compartilhar_view.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/views/configuracoes_view.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/views/document_list_view.dart';
import 'package:minha_saude_frontend/app/presentation/lixeira/views/lixeira_view.dart';
import 'package:minha_saude_frontend/app/presentation/shared/views/app_view.dart';
import 'package:minha_saude_frontend/app/presentation/shared/views/not_found.dart';

// Global key for the shell navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authRepository = getIt<AuthRepository>();
    final tokenRepository = getIt<TokenRepository>();

    // Check if user has a valid token
    final hasToken = tokenRepository.hasToken;

    // Check if user is registered (from cache only for router)
    final isRegisteredCached = hasToken
        ? authRepository.isRegisteredCached
        : false;

    final authRoutes = ['/login', '/tos', '/register'];
    final isOnAuthRoute = authRoutes.contains(state.fullPath);

    // If no token and not on auth route, go to login
    if (!hasToken && !isOnAuthRoute) {
      return '/login';
    }

    // If has token but registration status is not cached yet, let the app continue
    // The ViewModels will handle the async loading of registration status
    if (hasToken && isRegisteredCached == null) {
      // If on auth route, stay there until we know the registration status
      if (isOnAuthRoute) {
        return null;
      }
      // If not on auth route, let the destination handle the loading
      return null;
    }

    // If has token but not registered, user needs to complete registration
    if (hasToken && isRegisteredCached == false) {
      // First go to TOS, then to register
      if (state.fullPath != '/tos' && state.fullPath != '/register') {
        return '/tos';
      }
    }

    // If has token and is registered but on auth route, go to home
    if (hasToken && isRegisteredCached == true && isOnAuthRoute) {
      return '/';
    }

    return null;
  },
  errorBuilder: (context, state) => const NotFoundView(),
  routes: [
    // Main app routes with bottom navigation
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return AppView(navigationShell: navigationShell);
          },
      branches: [
        // Documents branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) =>
                  DocumentListView(
                    DocumentListViewModel(
                      getIt<AuthRepository>(),
                      getIt<TokenRepository>(),
                    ),
                  ),
            ),
          ],
        ),
        // Share branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/compartilhar',
              builder: (BuildContext context, GoRouterState state) =>
                  const CompartilharView(),
            ),
          ],
        ),
        // Trash branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lixeira',
              builder: (BuildContext context, GoRouterState state) =>
                  const LixeiraView(),
            ),
          ],
        ),
        // Settings branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/configuracoes',
              builder: (BuildContext context, GoRouterState state) =>
                  const ConfiguracoesView(),
            ),
          ],
        ),
      ],
    ),

    // Auth Routes (without bottom navigation)
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginView(
          LoginViewModel(getIt<AuthRepository>(), getIt<TokenRepository>()),
        );
      },
    ),
    GoRoute(
      path: '/tos',
      builder: (BuildContext context, GoRouterState state) {
        return TosView(TosViewModel());
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterView(
          RegisterViewModel(getIt<AuthRepository>(), getIt<TokenRepository>()),
        );
      },
    ),
  ],
);
