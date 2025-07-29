import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInButton extends StatelessWidget {
  final Text _label;
  final Widget _icon;

  const SignInButton({required Text label, required Widget icon, super.key})
    : _label = label,
      _icon = icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton.icon(
      label: _label,
      icon: SizedBox(width: 24, height: 24, child: _icon),
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        foregroundColor: theme.colorScheme.onSurface,
        shape: const StadiumBorder(),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

      // style: ButtonStyle(
      //   backgroundColor: WidgetStateProperty.all(
      //     theme.colorScheme.surfaceContainerLowest,
      //   ),
      //   textStyle: WidgetStateProperty.all(theme.textTheme.bodyLarge),
      //   shape: WidgetStateProperty.all(const StadiumBorder()),
      //   padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
      // ),