import 'dart:async';

import 'package:flutter/material.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator({
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final ValueNotifier<int> currentPage;
  final ValueNotifier<int> totalPages;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _fadeOutTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Show initially
    _fadeController.forward();
    _scheduleFadeOut();

    // Listen to page changes
    widget.currentPage.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.currentPage.removeListener(_onPageChanged);
    _fadeOutTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    // Cancel any existing timer (debounce behavior)
    _fadeOutTimer?.cancel();

    // Show the counter and schedule fade out
    _fadeController.forward();
    _scheduleFadeOut();
  }

  void _scheduleFadeOut() {
    // Cancel previous timer if it exists
    _fadeOutTimer?.cancel();

    // Create new timer
    _fadeOutTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.totalPages,
      builder: (context, totalPages, child) {
        return ValueListenableBuilder<int>(
          valueListenable: widget.currentPage,
          builder: (context, currentPage, child) {
            var theme = Theme.of(context);
            var colorScheme = theme.colorScheme;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$currentPage de $totalPages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
