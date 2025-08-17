import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import 'package:flutter/material.dart';

class RegisteredDateSelector extends StatelessWidget {
  final bool isReadOnly;
  final DateTime registeredDate;
  final void Function()? onPressed;

  const RegisteredDateSelector({
    super.key,
    required this.isReadOnly,
    required this.registeredDate,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              '등록일 ${isReadOnly ? '' : '(선택)'}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: RenderFilledButton(
                width: 100,
                backgroundColor: isReadOnly
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary,
                foregroundColor: isReadOnly
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onPrimary,
                borderRadius: 5,
                onPressed: isReadOnly ? null : onPressed,
                text: registeredDate.formattedBirth,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
