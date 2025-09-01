import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/register_screen_view_model.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/terms_conditions_view_model.dart';
import 'package:minha_saude_frontend/features/auth/ui/views/login_screen.dart';
import 'package:minha_saude_frontend/features/auth/ui/views/register_screen.dart';
import 'package:minha_saude_frontend/features/auth/ui/views/terms_conditions.dart';

GoRouter makeRouter() {
  final getIt = GetIt.I;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Temporary until SessionRepostiory is available
      final isLoggedIn = false;
      final authRoutes = ['/login', '/register', '/tos'];
      if (!isLoggedIn && !authRoutes.contains(state.path)) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return LoginScreen(viewModel: getIt<LoginViewModel>());
        },
      ),
      GoRoute(
        path: '/tos',
        builder: (BuildContext context, GoRouterState state) {
          return TermsConditions(viewModel: getIt<TermsConditionsViewModel>());
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return RegisterScreen(viewModel: getIt<RegisterScreenViewModel>());
        },
      ),
    ],
  );
}
