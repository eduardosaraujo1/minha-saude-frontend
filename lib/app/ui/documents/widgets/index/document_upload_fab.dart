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
            child: FloatingActionButton.extended(
              elevation: 1,
              label: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              icon: Icon(icon, color: colorScheme.onSecondaryContainer),
              onPressed: onPressed,
              backgroundColor: colorScheme.secondaryContainer,
              heroTag: heroTag,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Scan option (appears first, at the top)
        if (_isExpanded || _animationController.isAnimating)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
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
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildOptionButton(
              label: 'Carregar arquivo',
              icon: Icons.upload_file,
              onPressed: _handleUploadTap,
              slideAnimation: _uploadSlideAnimation,
              heroTag: 'upload_fab',
            ),
          ),

        // Main FAB
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FloatingActionButton(
              onPressed: _toggleMenu,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.add)],
              ),
            );
          },
        ),
      ],
    );
  }
}
