import 'package:withme/core/utils/get_earliest_upcoming_birthday.dart';

import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';
import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';
import 'birthday_badge.dart';

class InsuredMembersIcon extends StatelessWidget {
  final CustomerModel customer;
  final double size;

  const InsuredMembersIcon({super.key, required this.customer, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final List<PolicyModel> policies = customer.policies;
    final int totalCount = policies.length;
    final int displayCount = totalCount >= 5 ? 4 : totalCount;

    final List<Color> circleColors = [
      Colors.blueAccent,
      Colors.green,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];

    // 원 크기 및 위치 정의
    double circleSize;
    List<Offset> positions;

    switch (displayCount) {
      case 1:
        circleSize = size;
        positions = [const Offset(0, 0)];
        break;
      case 2:
        circleSize = size * 0.7;
        positions = [Offset(0, size * 0.15), Offset(size * 0.3, 0)];
        break;
      case 3:
        circleSize = size * 0.7;
        positions = [
          Offset(0, size * 0.2),
          Offset(size * 0.35, 0),
          Offset(size * 0.5, size * 0.4),
        ];
        break;
      default:
        circleSize = size * 0.6;
        positions = [
          const Offset(0, 0),
          Offset(size * 0.5, 0),
          Offset(0, size * 0.5),
          Offset(size * 0.5, size * 0.5),
        ];
    }

    // ✅ birthday 여부 체크
    final bool hasUpcomingBirthday = policies.any(
      (p) => p.insuredBirth != null && isBirthdayWithin7Days(p.insuredBirth!),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 원 표시
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: positions[i].dx,
              top: positions[i].dy + (circleSize / 2),
              child: _buildCircle(
                policies[i].insured.characters.firstOrNull ?? '?',
                circleSize,
                circleColors[i % circleColors.length],
              ),
            ),

          // 5개 이상일 경우 우측 상단 배지
          if (totalCount > 4)
            Positioned(
              top: -4,
              right: -4,
              child: _buildBadge(totalCount.toString(), Colors.purple),
            ),

          // ✅ 생일 배지 (좌측 하단)
          if (hasUpcomingBirthday)
            Positioned(
              top: 2,
              left: -2,
              child: BirthdayBadge(
                iconSize: 18,
                isShowDate: false,
                birth: getEarliestUpcomingBirthday(policies),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircle(String letter, double circleSize, Color color) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(fontSize: circleSize * 0.7, color: Colors.white),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
