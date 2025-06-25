import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class ItemIcon extends StatelessWidget {
  final int number;
  final double size;
  final String sex;
  final String backgroundImagePath;

  const ItemIcon({
    super.key,
    required this.number,
    this.size = 32,
    required this.sex,
    required this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.8; // 전체보다 작게 설정

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 좌측 하단 아이콘
          Positioned(

            bottom: 1,
            left: 1,
            child: ClipOval(
              child: Image.asset(
                backgroundImagePath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                color: getSexIconColor(sex),
              ),
            ),
          ),

          // 우측 상단 숫자
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              '$number',
              style: TextStyles.bold14, // 숫자가 너무 크지 않게 조정
            ),
          ),
        ],
      ),
    );
  }
}
