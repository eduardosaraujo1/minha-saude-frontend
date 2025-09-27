import 'package:flutter/material.dart';

class DocumentFab extends StatefulWidget {
  const DocumentFab({
    super.key,
    required this.menuItems,
    this.fabIcon = Icons.add,
    this.fabLabel,
    this.fabBackgroundColor,
    this.fabForegroundColor,
  });

  final List<DocumentFabMenuItem> menuItems;
  final IconData fabIcon;
  final String? fabLabel;
  final Color? fabBackgroundColor;
  final Color? fabForegroundColor;

  @override
  State<DocumentFab> createState() => _DocumentFabState();
}

class DocumentFabMenuItem {
  const DocumentFabMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class _DocumentFabState extends State<DocumentFab> {
  bool _isOpen = false;

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items when open
        if (_isOpen) ...[
          ...widget.menuItems.map(
            (item) => FilledButton.icon(
              onPressed: () {
                _toggleMenu();
                item.onPressed();
              },
              icon: Icon(item.icon, size: 20),
              label: Text(item.label),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.primaryContainer,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          // Close button
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: StadiumBorder(),
              mini: true,
              child: const Icon(Icons.close),
            ),
          ),
        ],
        // Main FAB
        Builder(
          builder: (context) {
            if (_isOpen) return SizedBox(height: 12);
            return widget.fabLabel != null
                ? FloatingActionButton.extended(
                    onPressed: _toggleMenu,
                    backgroundColor:
                        widget.fabBackgroundColor ??
                        colorScheme.primaryContainer,
                    foregroundColor:
                        widget.fabForegroundColor ??
                        colorScheme.onPrimaryContainer,
                    icon: Icon(
                      widget.fabIcon,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    label: Text(
                      widget.fabLabel!,
                      style: textTheme.labelLarge?.copyWith(
                        color:
                            widget.fabForegroundColor ??
                            colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : FloatingActionButton(
                    onPressed: _toggleMenu,
                    backgroundColor:
                        widget.fabBackgroundColor ?? colorScheme.primary,
                    foregroundColor:
                        widget.fabForegroundColor ?? colorScheme.onPrimary,
                    child: Icon(widget.fabIcon),
                  );
          },
        ),
      ],
    );
  }
}
