import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';

class SexIconWithBirthday extends StatelessWidget {
  final DateTime? birth;
  final double size;
  final String sex;
  final String backgroundImagePath;
  final bool isShowDay;

  const SexIconWithBirthday({
    super.key,
    required this.birth,
    this.size = 37,
    required this.sex,
    required this.backgroundImagePath,
    this.isShowDay = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool hasUpcomingBirthday =
        birth != null && isBirthdayWithin7Days(birth!);
    final int countdown = birth != null ? getBirthdayCountdown(birth!) : -1;

    // 아이콘 크기 결정: 다가오는 생일이면 70%, 아니면 기본 크기
    final double displaySize = hasUpcomingBirthday ? size * 0.6 : size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            width: displaySize,
            height: displaySize,
            color: getSexIconColor(sex, colorScheme).withValues(alpha: 0.6),
          ),
        ),
        if (hasUpcomingBirthday && isShowDay) ...[
        width(3),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cake_rounded,
                color: Colors.redAccent,
                size: size * 0.35,
              ),
              Flexible(
                child: Text(
                  countdown != 0 ? 'D-$countdown' : '오늘',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
