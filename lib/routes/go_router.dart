import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_screen_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/terms_conditions_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/login_page.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/register_page.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/tos_page.dart';

final getIt = GetIt.instance;

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Temporary until SessionRepostiory is available
    final isLoggedIn = false;
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
        return LoginPage(viewModel: getIt<LoginViewModel>());
      },
    ),
    GoRoute(
      path: '/tos',
      builder: (BuildContext context, GoRouterState state) {
        return TosPage(viewModel: getIt<TermsConditionsViewModel>());
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterPage(viewModel: getIt<RegisterScreenViewModel>());
      },
    ),
  ],
);
