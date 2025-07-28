import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class ProspectItemIcon extends StatelessWidget {
  final int number;
  final double size;
  final String sex;
  final String backgroundImagePath;

  const ProspectItemIcon({
    super.key,
    required this.number,
    this.size = 32,
    required this.sex,
    required this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 중앙 아이콘 이미지
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                backgroundImagePath,
                fit: BoxFit.cover,
                color: getSexIconColor(sex).withOpacity(0.6),
              ),
            ),
          ),

          // 숫자 배지
          if (number > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding:  EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorStyles.badgeColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 5,
                  minHeight: 5,
                ),
                child: Text(
                  '$number',
                  style: TextStyles.bold8.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
