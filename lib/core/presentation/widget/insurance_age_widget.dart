import '../../data/fire_base/user_session.dart';
import '../../di/setup.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/core_utils_import.dart';
import '../core_presentation_import.dart'; // width 함수

class InsuranceAgeWidget extends StatelessWidget {
  final DateTime birthDate;

  const InsuranceAgeWidget({super.key, required this.birthDate});

  @override
  Widget build(BuildContext context) {
    final userSession=getIt<UserSession>();
    final insuranceChangeDate=getInsuranceAgeChangeDate(birthDate);
    final int difference =
        insuranceChangeDate.difference(DateTime.now()).inDays;
    final bool isUrgent = difference <= userSession.urgentThresholdDays;

    return Row(
      children: [
        Text(
          '상령일: ${insuranceChangeDate.formattedDate}',
          style: TextStyles.normal12,
        ),
        width(6),
        // 음수 부호 포함 잔여일 텍스트
        Text(
          '(D-${difference.abs()})', // 항상 - 부호 붙이고 절댓값 표시
          style: TextStyles.normal12.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        if (isUrgent) ...[
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
