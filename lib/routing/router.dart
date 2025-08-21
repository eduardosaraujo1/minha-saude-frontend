import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/email_input_view_model.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/screens/login_screen.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/login_view_model.dart';

final getIt = GetIt.instance;

// Nota: Nested navigation/ShellRoute (seção configuration dos docs) serão usados para os documentos
final router = GoRouter(
  // TODO: se não estiver logado, redirecionar para a tela de login, e redirecionar tela de login para tela de documentos inicial
  initialLocation: '/login',
  redirect: (context, state) {
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginScreen(viewModel: getIt<LoginViewModel>());
      },
    ),
  ],
);
