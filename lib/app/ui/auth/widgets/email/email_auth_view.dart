import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/auth/login_response/login_result.dart';
import '../../../../routing/routes.dart';
import '../../view_models/email_auth_view_model.dart';
import '../layouts/login_form_layout.dart';

part 'code_request_form.dart';
part 'code_submission_form.dart';

class EmailAuthView extends StatefulWidget {
  const EmailAuthView({required this.viewModelFactory, super.key});

  final EmailAuthViewModel Function() viewModelFactory;

  @override
  State<EmailAuthView> createState() => _EmailAuthViewState();
}

class _EmailAuthViewState extends State<EmailAuthView> {
  late final EmailAuthViewModel viewModel = widget.viewModelFactory();

  @override
  void initState() {
    viewModel.requestCodeCommand.addListener(_onCodeRequest);
    viewModel.verifyCodeCommand.addListener(_onCodeVerify);
    super.initState();
  }

  @override
  void dispose() {
    viewModel.requestCodeCommand.removeListener(_onCodeRequest);
    viewModel.verifyCodeCommand.removeListener(_onCodeVerify);
    viewModel.dispose();
    super.dispose();
  }

  void _onCodeRequest() {
    if (!mounted) return;

    final result = viewModel.requestCodeCommand.value;
    if (result == null) return;

    if (result.isSuccess()) {
      // Navigate to code submission screen
      viewModel.stage.value = EmailRoutes.submitCode;
      return;
    }

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Não foi possível enviar o código. Tente novamente mais tarde.",
          ),
        ),
      );
    }
  }

  void _onCodeVerify() {
    if (!mounted) return;

    final result = viewModel.verifyCodeCommand.value;
    if (result == null) return;

    if (result.isSuccess()) {
      // Navigate to screen based of login result
      final loginResult = result.tryGetSuccess()!;
      switch (loginResult) {
        case SuccessfulLoginResult():
          context.go(Routes.home);
          break;
        case NeedsRegistrationLoginResult():
          context.go(Routes.register);
          break;
      }
      return;
    }

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Não foi possível verificar o código. Tente novamente mais tarde.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final current = viewModel.stage.value;

        if (current.index <= 0) {
          context.go(Routes.auth);
        }

        viewModel.stage.value = EmailRoutes.values[current.index - 1];
      },
      child: ValueListenableBuilder(
        valueListenable: viewModel.stage,
        builder: (context, currentStage, child) {
          return IndexedStack(
            index: currentStage.index,
            children: [
              CodeRequestForm(viewModel: viewModel),
              CodeSubmissionForm(viewModel: viewModel),
            ],
          );
        },
      ),
    );
  }
}
