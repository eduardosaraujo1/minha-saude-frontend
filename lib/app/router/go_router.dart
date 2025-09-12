import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/di/get_it.dart';
import 'package:minha_saude_frontend/app/domain/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/tos_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/login_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/register_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/tos_view.dart';
import 'package:minha_saude_frontend/app/presentation/shared/views/not_found.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authRepository = getIt<IAuthRepository>();

    // Check if user has a valid token
    final hasToken = authRepository.getToken() != null;

    // Check if user is registered (for users with token)
    final isRegistered = hasToken ? authRepository.isRegistered() : false;

    final authRoutes = ['/login', '/register', '/tos'];
    final isOnAuthRoute = authRoutes.contains(state.fullPath);

    // If no token and not on auth route, go to login
    if (!hasToken && !isOnAuthRoute) {
      return '/login';
    }

    // If has token but not registered and not on register route, go to register
    if (hasToken && !isRegistered && state.fullPath != '/register') {
      return '/register';
    }

    // If has token and is registered but on auth route, go to home
    if (hasToken && isRegistered && isOnAuthRoute) {
      return '/'; // or '/home' depending on your setup
    }

    return null;
  },
  errorBuilder: (context, state) => const NotFoundView(),
  routes: [
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginView(LoginViewModel(getIt<IAuthRepository>()));
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
        return RegisterView(RegisterViewModel(getIt<IAuthRepository>()));
      },
    ),
  ],
);
