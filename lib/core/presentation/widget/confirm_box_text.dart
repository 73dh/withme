import 'package:flutter/material.dart';

class ConfirmBoxText extends StatelessWidget {
  final String? text;
  final String? text2;
  final double size;
  final TextStyle? textStyle;

  const ConfirmBoxText({
    super.key,
    this.text,
    this.text2,
    this.size = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = textStyle ?? theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RichText(
        text: TextSpan(
          style: baseStyle?.copyWith(fontSize: size),
          children: [
            TextSpan(text: text, style: baseStyle),
            TextSpan(
              text: text2,
              style: baseStyle?.copyWith(
                color: theme.colorScheme.primary, // 강조 색상
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
