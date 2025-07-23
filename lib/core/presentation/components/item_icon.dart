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

//
// class ItemIcon extends StatelessWidget {
//   final int number;
//   final double size;
//   final String sex;
//   final String backgroundImagePath;
//
//   const ItemIcon({
//     super.key,
//     required this.number,
//     this.size = 32,
//     required this.sex,
//     required this.backgroundImagePath,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final double iconSize = size * 0.8;
//
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             offset: const Offset(4, 4),
//             blurRadius: 6,
//             spreadRadius: 3,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // 좌측 하단 아이콘
//           Positioned(
//             bottom: 1,
//             left: 1,
//             child: ClipOval(
//               child: Image.asset(
//                 backgroundImagePath,
//                 width: iconSize,
//                 height: iconSize,
//                 fit: BoxFit.cover,
//                 color: getSexIconColor(sex).withOpacity(0.5), // 🎯 투명도 조절
//               ),
//             ),
//           ),
//
//           // 우측 상단 숫자
//           Positioned(
//             top: 0,
//             right: 0,
//             child: Text(
//               '$number',
//               style: TextStyles.bold14, // 숫자가 너무 크지 않게 조정
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
