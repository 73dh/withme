import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class BuildMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool? isActivated;

  const BuildMenuItem({super.key, required this.icon, required this.text, this.onTap, this.isActivated=true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: isActivated == true ? ColorStyles.dashBoardIconColor : Colors.grey),
          width(5),
          Text(
            text,
            style: TextStyle(color: isActivated == true ? null : Colors.grey),
          ),
        ],
      ),
    );
  }
}
