import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/config/asset.dart';

/// A wrapper around AppBar that includes the Minha Saúde brand icon.
///
/// Shows the brand logo on the left (hidden when back button is present)
/// and allows for a flexible action widget on the right.
///
/// Example usage:
/// ```dart
/// BrandAppbar(
///   title: Text('Configurações'),
///   action: IconButton(
///     icon: Icon(Icons.more_vert),
///     onPressed: () => _showMenu(),
///   ),
/// )
/// ```
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title widget to display
  final Widget? title;

  /// Action widget to display on the right (constrained to 48x48)
  final Widget? action;

  final PreferredSizeWidget? bottom;

  const BrandAppBar({super.key, this.title, this.action, this.bottom});

  @override
  Widget build(BuildContext context) {
    final bool canPop = context.canPop();

    return AppBar(
      backgroundColor: const Color(0xFFE9EFF1),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: canPop ? null : _buildBrandIcon(),
      bottom: bottom,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [if (title != null) Flexible(child: title!)],
      ),
      actions: action != null
          ? [SizedBox(width: 48.0, height: 48.0, child: action!)]
          : null,
      automaticallyImplyLeading: true,
    );
  }

  /// Builds the brand icon
  Widget _buildBrandIcon() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SvgPicture.asset(
        Asset.minhaSaudeLogoIcon,
        width: 32.0,
        height: 32.0,
        semanticsLabel: 'Ícone Minha Saúde',
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
