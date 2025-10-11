import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minha_saude_frontend/config/asset.dart';

class LoginDecorator extends StatelessWidget {
  const LoginDecorator({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(128)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: SvgPicture.asset(Asset.minhaSaudeLogo),
        ),
      ),
    );
  }
}
