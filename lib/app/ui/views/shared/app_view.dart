import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/navbar.dart';

class AppView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppView({super.key, required this.navigationShell});

  void _onDestinationSelected(BuildContext context, int index) {
    // Use the StatefulNavigationShell's goBranch method for proper navigation
    navigationShell.goBranch(
      index,
      // Optional: include initialLocation to reset the branch's stack
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Navbar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
      ),
    );
  }
}
