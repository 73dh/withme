import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart';

class InsuranceAgeWidget extends StatelessWidget {
  final int difference;
  final bool isUrgent;
  final DateTime insuranceChangeDate;
  final ColorScheme colorScheme;
  final bool isCustomerItem;
  final bool isShowText;

  const InsuranceAgeWidget({
    super.key,
    required this.difference,
    required this.isUrgent,
    required this.insuranceChangeDate,
    required this.colorScheme,
    this.isCustomerItem = true,
    this.isShowText=true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFuture = difference >= 0;

    return Row(
      mainAxisSize: MainAxisSize.min, // Row 최소 폭만 차지
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(isShowText)
        Flexible(
          child:Text(
            '[상령일] ${insuranceChangeDate.formattedMonthAndDate}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        width(4),
        if (!isCustomerItem)
          Flexible(
            child: Text(
              isFuture ? '(D-$difference)' : '(D+${difference.abs()})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isFuture ? colorScheme.primary : colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (isFuture && isUrgent) ...[
          width(6),
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
        ],
      ],
    );
  }
}
