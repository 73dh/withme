import '../../ui/core_ui_import.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';

class InsuranceAgeWidget extends StatelessWidget {
  final int difference;
  final bool isUrgent;
  final DateTime insuranceChangeDate;

  const InsuranceAgeWidget({
    super.key,
    required this.difference,
    required this.isUrgent,
    required this.insuranceChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isFuture = difference >= 0;

    return Row(
      children: [
        Text(
          '[상령일] ${insuranceChangeDate.formattedMonthAndDate}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        width(6),
        Text(
          isFuture ? '(D-$difference)' : '(D+${difference.abs()})',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isFuture
                ? colorScheme.primary   // 미래 → 강조 색
                : colorScheme.onSurface, // 지난 날짜 → 기본 텍스트 색
            fontWeight: FontWeight.normal,
          ),
        ),
        if (isFuture && isUrgent) ...[
          width(4),
          RotatingDots(
            size: 15,
            dotBaseSize: 4,
            dotPulseRange: 2,
            // ✅ theme 기반 색상 적용
            colors: [
              colorScheme.error,
              colorScheme.primary,
            ],
          ),
        ],
      ],
    );
  }
}
