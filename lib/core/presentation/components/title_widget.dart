import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final TextStyle? textStyle; // 추가
  const TitleWidget({super.key, required this.title, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style:
          textStyle ??
          theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
    );
  }
}
