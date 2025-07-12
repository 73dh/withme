import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class BuildIconRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor = ColorStyles.dashBoardIconColor;
  final String text;
   BuildIconRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        width(5),
        Expanded(child: Text(text)),
      ],
    );
  }
}
