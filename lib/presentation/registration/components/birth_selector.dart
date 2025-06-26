import 'package:flutter/material.dart';

import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/core_utils_import.dart';

class BirthSelector extends StatelessWidget {
  final bool isReadOnly;
  final DateTime? birth;
  final void Function()? onInitPressed;
  final void Function()? onSetPressed;

  const BirthSelector({
    super.key,
    required this.isReadOnly,
    this.birth,
    required this.onInitPressed,
    required this.onSetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('생년월일 ${isReadOnly ? '' : '(선택)'}'),
            const Spacer(),
            if (birth != null)
              RenderFilledButton(
                width: 100,

                backgroundColor: ColorStyles.activeButtonColor,
                borderRadius: 5,
                onPressed: onInitPressed,
                text: '초기화',
              ),
            SizedBox(
              width: 120,
              child: RenderFilledButton(
                width: 100,
                backgroundColor: ColorStyles.activeButtonColor,
                borderRadius: 5,
                onPressed: onSetPressed,
                text: birth != null ? birth!.formattedDate : '생년월일',
              ),
            ),
          ],
        ),
        if (birth != null) ...[
          height(5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${calculateAge(birth!)}세 (보험나이: ${calculateInsuranceAge(birth!)}세), 상령일까지 ${daysUntilInsuranceAgeChange(birth!)}일',
            ),
          ),
        ],
      ],
    );
  }
}
