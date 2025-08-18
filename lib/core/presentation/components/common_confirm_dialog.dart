import 'package:flutter/material.dart';

import '../core_presentation_import.dart';

class CommonConfirmDialog extends StatelessWidget {
  final String text;
  final List<TextSpan> textSpans;
  final String confirmButtonText;
  final String cancelButtonText;
  final Future<void> Function() onConfirm;
  final Color backgroundColor;
  final Color confirmButtonColor;
  final Color cancelButtonColor;
  final Color confirmTextColor;
  final Color cancelTextColor;

  const CommonConfirmDialog({
    super.key,
    required this.text,
    required this.textSpans,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
    required this.backgroundColor,
    required this.confirmButtonColor,
    required this.cancelButtonColor,
    required this.confirmTextColor,
    required this.cancelTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: backgroundColor,
      content:
          textSpans.isNotEmpty
              ? RichText(text: TextSpan(children: textSpans))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
      actions: [
        if (cancelButtonText.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: cancelTextColor,
              backgroundColor: cancelButtonColor,
            ),
            child: Text(cancelButtonText),
          ),
        ElevatedButton(
          onPressed: () async {
            await onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor,
            foregroundColor: confirmTextColor,
          ),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
