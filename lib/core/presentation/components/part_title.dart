import 'package:flutter/material.dart';

class PartTitle extends StatelessWidget {
  final String text;
  final double verticalPadding;
  final TextStyle? style;
  final Color? color;

  const PartTitle({
    super.key,
    required this.text,
    this.verticalPadding = 6,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          Text(
            text,
            style:
                style ??
                textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: color ?? colorScheme.onSurface,
                ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
