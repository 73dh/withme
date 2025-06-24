import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class ProspectItemIcon extends StatelessWidget {
  final int number;
  final double size;
  final String sex;
  final String backgroundImagePath; // 추가: PNG 아이콘 경로

  const ProspectItemIcon({
    super.key,
    required this.number,
    this.size = 32,
    required this.sex,
    required this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 PNG 이미지
          ClipOval(
            child: Image.asset(
              backgroundImagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              color:getSexIconColor(sex),
            ),
          ),

          // 숫자
          Text(
            '$number',
            style: TextStyles.bold20,
          ),
        ],
      ),
    );
  }
}
