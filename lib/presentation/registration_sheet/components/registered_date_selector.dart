import 'package:flutter/material.dart';
import 'package:withme/core/utils/core_utils_import.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Text('등록일 ${isReadOnly ? '' : '(선택)'}'),
            const Spacer(),

            SizedBox(
              width: 120,
              child: RenderFilledButton(
                width: 100,
                backgroundColor: ColorStyles.unActiveButtonColor,
                borderRadius: 5,
                onPressed: onPressed,
                text: registeredDate.formattedBirth,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
