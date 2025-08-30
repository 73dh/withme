import 'package:flutter/material.dart';
import 'package:withme/core/utils/get_sex_icon_color.dart';

import '../../../domain/model/customer_model.dart';

class FirstNameIcon extends StatelessWidget {
  final CustomerModel customer;
  final double size;
  final double badgeSize;
  final int todoCount; // ✅ 추가

  const FirstNameIcon({
    super.key,
    required this.customer,
    this.size = 40,
    this.badgeSize = 10,
    this.todoCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = getSexIconColor(customer.sex, colorScheme);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 기본 원형 아이콘
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.5,
            ),
          ),
        ),

        // 우측 상단 배지
        if (todoCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error, // ✅ 테마 색상 적용
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              child: Text(
                '$todoCount',
                style: TextStyle(
                  color: colorScheme.onError, // ✅ error 배경에 대비되는 텍스트 색
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
