import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';

class BirthdayBadge extends StatelessWidget {
  final DateTime birth;
  final Color cakeColor;
  final double iconSize;
  final double textSize; // ✅ 추가: 텍스트 크기 조절

  const BirthdayBadge({
    super.key,
    required this.birth,
    this.cakeColor = Colors.redAccent,
    this.iconSize = 28,
    this.textSize = 18, // 기본값
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUpcomingBirthday = isBirthdayWithin7Days(birth);
    final int countdown = getBirthdayCountdown(birth);

    if (!hasUpcomingBirthday) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cake_rounded,
          color: cakeColor,
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Text(
          countdown != 0 ? '-$countdown' : '오늘',
          style: TextStyle(
            fontSize: textSize,          // ✅ 텍스트 크기 적용
            color: cakeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
