import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/shared/widgets/navbar.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: Navbar());
  }
}
