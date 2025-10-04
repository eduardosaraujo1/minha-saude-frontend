import 'package:flutter/material.dart';

class DocumentUploadFab extends StatefulWidget {
  const DocumentUploadFab({
    super.key,
    required this.onScanTap,
    required this.onUploadTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback onUploadTap;

  @override
  State<DocumentUploadFab> createState() => _DocumentUploadFabState();
}

class _DocumentUploadFabState extends State<DocumentUploadFab>
    with SingleTickerProviderStateMixin {
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
