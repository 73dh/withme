import '../../../core/const/shared_pref_value.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/utils/core_utils_import.dart';

class BirthSelector extends StatelessWidget {
  final bool isReadOnly;
  final DateTime? birth;
  final void Function()? onInitPressed;
  final void Function(DateTime)? onSetPressed;
  final TextStyle? textStyle;

  const BirthSelector({
    super.key,
    required this.isReadOnly,
    this.birth,
    required this.onInitPressed,
    required this.onSetPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final urgentThresholdDays = SharedPrefValue.urgentThresholdDays;
    final daysLeft = birth != null ? daysUntilInsuranceAgeChange(birth!) : null;
    final isUrgent = daysLeft != null && daysLeft > 0 && daysLeft <= urgentThresholdDays;
    final isPassed = daysLeft != null && daysLeft < 0;
    final passedDays = isPassed ? daysLeft!.abs() : null;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '생년월일 ${isReadOnly ? '' : '(선택)'}',
              style: textStyle ??
                  textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Spacer(),
            if (birth != null && !isReadOnly)
              ElevatedButton(
                onPressed: onInitPressed,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
                child: const Icon(Icons.refresh, size: 18),
              ),
            const SizedBox(width: 5),
            SizedBox(
              width: 120,
              child: RenderFilledButton(
                width: 100,
                backgroundColor: birth != null
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary,
                foregroundColor: isReadOnly
                    ? colorScheme.onSurfaceVariant
                    : (birth != null
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onPrimary),
                borderRadius: 5,
                onPressed: isReadOnly
                    ? null
                    : () async {
                  final date = await selectDate(context);
                  if (date != null) onSetPressed?.call(date);
                },
                text: birth?.formattedBirth ?? '선택',
              ),
            ),
          ],
        ),
        if (birth != null) ...[
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상령일 텍스트
                Text.rich(
                  TextSpan(
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    children: [
                      TextSpan(
                        text:
                        '${calculateAge(birth!)}세 (보험나이: ${calculateInsuranceAge(birth!)}세), ',
                      ),
                      if (isPassed)
                        TextSpan(
                          text: '상령일 ${passedDays}일 경과',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.error,
                          ),
                        )
                      else
                        TextSpan(
                          text: '상령일까지 $daysLeft일',
                          style: isUrgent
                              ? TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.error,
                          )
                              : null,
                        ),
                    ],
                  ),
                ),


                if (isUrgent) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: RotatingDots(
                      size: 17,
                      dotBaseSize: 4,
                      dotPulseRange: 2,
                      colors: [colorScheme.error, colorScheme.primary],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ],
    );
  }
}
