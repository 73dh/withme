import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';

class BirthdayBadge extends StatelessWidget {
  final DateTime? birth;
  final Color cakeColor;
  final double iconSize;
  final double textSize;
  final bool isShowDate;

  const BirthdayBadge({
    super.key,
    required this.birth,
    this.cakeColor = Colors.redAccent,
    this.iconSize = 28,
    this.textSize = 18,
    this.isShowDate=true,
  });

  @override
  Widget build(BuildContext context) {
    if (birth == null) return const SizedBox.shrink(); // ✅ birth 없으면 아무것도 안 그림

    final bool hasUpcomingBirthday = isBirthdayWithin7Days(birth!);
    final int countdown = getBirthdayCountdown(birth!);

    if (!hasUpcomingBirthday) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cake_rounded, color: cakeColor, size: iconSize),
        const SizedBox(width: 2),
        if(isShowDate)
        Text(
          countdown != 0 ? '-$countdown' : '오늘',
          style: TextStyle(
            fontSize: textSize,
            color: cakeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
