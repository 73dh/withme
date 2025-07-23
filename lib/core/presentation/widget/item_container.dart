import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class ItemContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color? backgroundColor;

  const ItemContainer({super.key, required this.child, this.height=88, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color:backgroundColor?? ColorStyles.customerItemColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // 그림자 색상
            offset: const Offset(3, 3), // x, y 방향 으로 이동 (오른쪽 아래)
            blurRadius: 6, // 흐림 정도
            spreadRadius: 1, // 퍼짐 정도
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: child,
      ),
    );
  }
}
