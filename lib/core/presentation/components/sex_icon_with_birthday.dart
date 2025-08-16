import '../../ui/core_ui_import.dart';
import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/is_birthday_within_7days.dart';
import '../core_presentation_import.dart';
import 'package:flutter/material.dart';

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool hasUpcomingBirthday =
        birth != null && isBirthdayWithin7Days(birth!);
    final int countdown = birth != null ? getBirthdayCountdown(birth!) : -1;

    // SexIcon 원래 크기는 그대로 유지
    final double iconSize = size;

    // 케이크와 D-day 텍스트 크기는 SexIcon 크기에 비례해서 작게 설정
    final double cakeIconSize = iconSize * 0.4;
    final double dDayFontSize = iconSize * 0.3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            width:birth!=null? iconSize*0.7:iconSize,
            height: birth!=null? iconSize*0.7:iconSize,
            color: getSexIconColor(sex, colorScheme).withValues(alpha: 0.6),
          ),
        ),
        if (hasUpcomingBirthday && isShowDay) ...[
          // const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cake_rounded,
                color: Colors.redAccent,
                size: cakeIconSize,
              ),
              const SizedBox(height: 1),
              Text(
                countdown != 0 ? 'D-$countdown' : '오늘',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: dDayFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
