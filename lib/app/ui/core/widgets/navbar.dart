import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const Navbar({super.key, this.selectedIndex = 0, this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Documentos',
        ),
        NavigationDestination(
          icon: Icon(Icons.share_outlined),
          selectedIcon: Icon(Icons.share),
          label: 'Compartilhar',
        ),
        NavigationDestination(
          icon: Icon(Icons.delete_outlined),
          selectedIcon: Icon(Icons.delete),
          label: 'Lixeira',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Configurações',
        ),
      ],
    );
  }
}
