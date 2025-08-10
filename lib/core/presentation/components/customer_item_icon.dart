import '../../../domain/domain_import.dart';
import '../../../domain/model/policy_model.dart';
import '../core_presentation_import.dart';

class CustomerItemIcon extends StatelessWidget {
  final CustomerModel customer;
  final double size;

  const CustomerItemIcon({super.key, required this.customer, this.size = 32});

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
        circleSize = size; // 1개일 땐 기본 크기
        positions = [const Offset(0, 0)];
        break;
      case 2:
        circleSize = size * 0.7; // 2개 이상부터 조금 키움
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
              top: positions[i].dy,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
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
        color: color.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: circleSize * 0.7,
          // fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
