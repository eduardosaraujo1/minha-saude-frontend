import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownTextScroller extends StatelessWidget {
  const MarkdownTextScroller({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Markdown(
          data: text,
          selectable: true,
          padding: EdgeInsets.zero,
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyMedium,
            h3: theme.textTheme.titleMedium,
          ),
        ),
        // child: SingleChildScrollView(
        //   child: Text(text, style: theme.textTheme.bodyMedium),
        // ),
      ),
    );
  }
}
