import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/register_view_model.dart';

import '../../../../routing/routes.dart';
import 'register_tos.dart';
import 'register_view.dart';

abstract class RegisterRoutes {
  static const tos = '/tos';
  static const form = '/form';
}

class RegisterNavigator extends StatefulWidget {
  const RegisterNavigator({required this.viewModelFactory, super.key});

  final RegisterViewModel Function() viewModelFactory;

  @override
  State<RegisterNavigator> createState() => _RegisterNavigatorState();
}

class _RegisterNavigatorState extends State<RegisterNavigator> {
  late final RegisterViewModel viewModel = widget.viewModelFactory();
  @override
  void initState() {
    viewModel.registerCommand.addListener(_onRegisterUpdate);
    viewModel.loadTosCommand.addListener(_onTosLoad);
    viewModel.loadTosCommand.execute();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.registerCommand.removeListener(_onRegisterUpdate);
    viewModel.loadTosCommand.removeListener(_onTosLoad);
    viewModel.dispose();
    super.dispose();
  }

  void _onTosLoad() {
    if (!mounted) return;
    final val = viewModel.loadTosCommand.value;
    if (val == null) return;

    if (val.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar os Termos de Serviço. Por favor, tente novamente mais tarde.',
          ),
        ),
      );
    }
  }

  void _onRegisterUpdate() {
    if (!mounted) return;
    final val = viewModel.registerCommand.value;
    if (val == null) return;

    if (val.isSuccess()) {
      context.go(Routes.home);
      return;
    }

    if (val.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao completar o registro. Por favor, tente novamente mais tarde.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var navigatorKey = GlobalKey<NavigatorState>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
          return;
        }
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: RegisterRoutes.tos,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case RegisterRoutes.tos:
              return MaterialPageRoute(
                builder: (context) => RegisterTos(viewModel: viewModel),
              );
            case RegisterRoutes.form:
              return MaterialPageRoute(
                builder: (context) => RegisterView(viewModel: viewModel),
              );
            default:
              // throw Exception('Invalid route: ${settings.name}');
              return null;
          }
        },
      ),
    );
  }
}
