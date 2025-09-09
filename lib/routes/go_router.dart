import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/login_page.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/register_page.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/tos_page.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
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
        return LoginPage();
      },
    ),
    GoRoute(
      path: '/tos',
      builder: (BuildContext context, GoRouterState state) {
        return TosPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterPage();
      },
    ),
  ],
);
