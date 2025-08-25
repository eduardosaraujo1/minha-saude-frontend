import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

GoRouter makeRouter() {
  final getIt = GetIt.instance;
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!isLoggedIn && state.path != '/login') {
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
