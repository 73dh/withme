import 'package:flutter/material.dart';

import '../../../core/presentation/core_presentation_import.dart';
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
              FilledButton.tonal(
                onPressed: onInitPressed,
                child: const Text('초기화'),
              ),
            SizedBox(
              width: 120,
              child: FilledButton.tonal(
                onPressed: onSetPressed,
                child: Text(birth != null ? birth!.formattedDate : '생년월일'),
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
