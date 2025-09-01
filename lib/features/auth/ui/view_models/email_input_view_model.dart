import 'package:flutter/material.dart';

class EmailInputViewModel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu e-mail';
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  void dispose() {
    emailController.dispose();
  }
}
