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

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authRepository = getIt<AuthRepository>();
    final isLoggedIn = authRepository.isLoggedIn();

    final authRoutes = ['/login', '/register', '/tos'];
    final allowedRoutes = authRoutes.contains(state.fullPath);
    if (!isLoggedIn && !allowedRoutes) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginView(LoginViewModel(getIt<AuthRepository>()));
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
        return RegisterView(RegisterViewModel(getIt<AuthRepository>()));
      },
    ),
  ],
);
