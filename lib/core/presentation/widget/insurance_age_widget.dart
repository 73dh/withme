import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart'; // width 함수

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
    final bool isFuture = difference >= 0;

    return Row(
      children: [
        Text(
          '(상) ${insuranceChangeDate.formattedMonthAndDate}',
          style: TextStyles.normal12,
        ),
        width(6),
        Text(
          isFuture ? '(D-$difference)' : '(D+${difference.abs()})',
          style: TextStyles.normal12.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (isFuture && isUrgent) ...[
          width(4),
          const RotatingDots(
            size: 15,
            dotBaseSize: 4,
            dotPulseRange: 2,
            colors: [Colors.red, Colors.blue],
          ),
        ],
      ],
    );
  }
}
