import 'package:flutter/material.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class BuildIconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final TextStyle? textStyle;

  const BuildIconRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final resolvedTextStyle = textStyle?.copyWith(
      color: textStyle?.color ?? colorScheme.onSurface,
    ) ??
        textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 20,
        ),
        width(5),
        Expanded(
          child: Text(
            text,
            style: resolvedTextStyle,
          ),
        ),
      ],
    );
  }
}
