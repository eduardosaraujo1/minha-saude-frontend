import 'package:flutter/material.dart';

class DocumentUploadFab extends StatefulWidget {
  const DocumentUploadFab({
    required this.onScanTap,
    required this.onUploadTap,
    super.key,
  });

  final VoidCallback onScanTap;
  final VoidCallback onUploadTap;

  @override
  State<DocumentUploadFab> createState() => _DocumentUploadFabState();
}

class _DocumentUploadFabState extends State<DocumentUploadFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fabExtensionAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _uploadSlideAnimation;
  late Animation<double> _scanSlideAnimation;
  late Animation<double> _optionsFadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animation for the main FAB transitioning from extended to normal
    _fabExtensionAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    // Icon rotation (+ to x)
    _iconRotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.125, // 45 degrees (1/8 turn)
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
          ),
        );

    // Upload option (appears second, closer to main FAB)
    _uploadSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Scan option (appears first, furthest from main FAB)
    _scanSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Fade animation for options
    _optionsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleScanTap() {
    _toggleMenu();
    widget.onScanTap();
  }

  void _handleUploadTap() {
    _toggleMenu();
    widget.onUploadTap();
  }

  Widget _buildOptionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Animation<double> slideAnimation,
    required String heroTag,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, child) {
        // Calculate slide offset with push-up effect
        final offset = Offset(0, (1 - slideAnimation.value) * 50);

        return Transform.translate(
          offset: offset,
          child: Opacity(
            opacity: _optionsFadeAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: colorScheme.surface,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  heroTag: heroTag,
                  onPressed: onPressed,
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  child: Icon(icon),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Scan option (appears first, at the top)
        if (_isExpanded || _animationController.isAnimating)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildOptionButton(
              label: 'Escanear',
              icon: Icons.document_scanner,
              onPressed: _handleScanTap,
              slideAnimation: _scanSlideAnimation,
              heroTag: 'scan_fab',
            ),
          ),

        // Upload option (appears second, in the middle)
        if (_isExpanded || _animationController.isAnimating)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildOptionButton(
              label: 'Carregar arquivo',
              icon: Icons.upload_file,
              onPressed: _handleUploadTap,
              slideAnimation: _uploadSlideAnimation,
              heroTag: 'upload_fab',
            ),
          ),

        // Main FAB with smooth transition between extended and normal
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final isExtended = _fabExtensionAnimation.value > 0.5;

            return RotationTransition(
              turns: _iconRotationAnimation,
              child: FloatingActionButton(
                onPressed: _toggleMenu,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isExpanded ? Icons.close : Icons.add),
                    if (isExtended) ...[
                      SizedBox(width: 8 * _fabExtensionAnimation.value),
                      Opacity(
                        opacity: _fabExtensionAnimation.value,
                        child: const Text('Documento'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
