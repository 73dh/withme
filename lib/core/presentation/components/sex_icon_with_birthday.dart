import '../../ui/core_ui_import.dart';
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
    final bool hasUpcomingBirthday =
        birth != null && isBirthdayWithin7Days(birth!);
    final int countdown = birth != null ? getBirthdayCountdown(birth!) : -1;

    final double iconSize =
        hasUpcomingBirthday && isShowDay ? size * 0.75 : size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            width: iconSize,
            height: iconSize,
            color: getSexIconColor(sex).withOpacity(0.6),
          ),
        ),
        if (hasUpcomingBirthday && isShowDay) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cake_rounded,
                color: ColorStyles.cakeColor,
                size: iconSize * 0.6,
              ),
              const SizedBox(height: 2),
              Text(
                countdown != 0 ? 'D-$countdown' : '오늘',
                style: TextStyles.bold12.copyWith(color: ColorStyles.cakeColor),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
