import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DocumentItem extends StatelessWidget {
  const DocumentItem({
    super.key,
    required this.title,
    this.onTap,
    this.textStyle,
  });

  final String title;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/document.svg',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
