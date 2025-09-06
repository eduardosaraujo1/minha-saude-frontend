import 'package:flutter/material.dart';

class ButtonSignIn extends StatelessWidget {
  const ButtonSignIn({
    required this.label,
    required this.icon,
    this.disabled = false,
    this.onPressed,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        label: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: disabled
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          ),
        ),
        icon: SizedBox(width: 24, height: 24, child: icon),
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: disabled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerLowest,
          foregroundColor: disabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface,
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
