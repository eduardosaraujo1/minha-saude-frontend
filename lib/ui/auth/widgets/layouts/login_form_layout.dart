import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginFormLayout extends StatelessWidget {
  final Widget child;

  const LoginFormLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LoginTopBar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    // Extracted sizes for future responsiveness
    const double layoutHeight = 196;
    const double circleSize = 64;

    return SizedBox(
      height: layoutHeight,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LoginDecoratorVariant(circleSize: circleSize),
          ),
        ],
      ),
    );
  }
}

class LoginDecoratorVariant extends StatelessWidget {
  const LoginDecoratorVariant({super.key, required this.circleSize});

  final double circleSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: constraints.maxHeight * 0.5 - circleSize / 2,
              child: DecoratorCircle(
                circleSize: circleSize,
                color: theme.colorScheme.primary,
              ),
            ),
            Positioned(
              left: constraints.maxWidth - circleSize,
              top: 0,
              child: DecoratorCircle(
                circleSize: circleSize,
                color: theme.colorScheme.secondary,
              ),
            ),
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'assets/brand/minha_saude/logo_icon.svg',
                  width: 100,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DecoratorCircle extends StatelessWidget {
  const DecoratorCircle({
    super.key,
    required this.circleSize,
    required this.color,
  });

  final double circleSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
