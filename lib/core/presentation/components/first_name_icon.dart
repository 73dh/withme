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
    this.size = 38,
    this.badgeSize = 12,
    this.todoCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = getSexIconColor(customer.sex, colorScheme);

    // 원형 아이콘 본체
    final circle = Container(
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
    );

    // todoCount가 있으면 Badge로 감싸기
    return todoCount > 0
        ? Badge(
          alignment: Alignment.topRight,
          offset: const Offset(4, -4),
          // 위치 조정
          backgroundColor: colorScheme.error,
          padding: const EdgeInsets.all(2),
          // ✅ 기본보다 작은 패딩
          label: Text(
            '$todoCount',
            style: TextStyle(
              color: colorScheme.onError,
              fontSize: 7, // ✅ 글자 크기 줄임
              fontWeight: FontWeight.bold,
            ),
          ),
          child: circle,
        )
        : circle;
  }
}
