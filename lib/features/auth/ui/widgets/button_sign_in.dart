import 'package:flutter/material.dart';

class ButtonSignIn extends StatelessWidget {
  const ButtonSignIn({
    required this.label,
    required this.icon,
    this.onPressed,
    super.key,
  });

  final Text label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        label: label,
        icon: SizedBox(width: 24, height: 24, child: icon),
        onPressed: onPressed ?? () {},
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          foregroundColor: theme.colorScheme.onSurface,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
