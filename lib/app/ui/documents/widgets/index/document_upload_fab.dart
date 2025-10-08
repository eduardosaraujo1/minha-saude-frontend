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
  /* 
      I want to change this animation to a more complex one which I do not know how to do
      I hope you can help me with that
      ---
      The animation should be like this:
      - By default the FAB is an extended FAB with a '+' icon and the label 'Documento'
      - When tapped, the FAB should be replaced with a non-extended FAB with a 'x' icon
      - Two smaller FABs should appear above the main FAB with a push-up effect, one with a 'document_scanner' icon and the label 'Escanear', and another with an 'upload_file' icon and the label 'Carregar arquivo'
      - Note that the push effect should be animated, and the smaller FABs should not be visible before they were pushed out of the non-extended FAB (like, the non-extended FAB has a pure white background and the smaller FABs are hidden behind it)
      - The reverse effect is a push-down effect followed by the main FAB turning back into an extended FAB with a '+' icon and the label 'Documento'
      */
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.125, // 45 degrees (1/8 turn)
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Scan option
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
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
                      child: Text(
                        'Escanear',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'scan_fab',
                    onPressed: _handleScanTap,
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.document_scanner),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Upload option
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
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
                      child: Text(
                        'Carregar arquivo',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'upload_fab',
                    onPressed: _handleUploadTap,
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.upload_file),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main FAB
        RotationTransition(
          turns: _rotationAnimation,
          child: FloatingActionButton.extended(
            label: Text('Documento'),
            onPressed: _toggleMenu,
            icon: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}
