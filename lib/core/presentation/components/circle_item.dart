import 'package:flutter/material.dart';

import '../../ui/text_style/text_styles.dart';


class CircleItem extends StatelessWidget {
  final int number;
  final Color? color;
  final double size;
  const CircleItem({super.key, required this.number, required this.color,  this.size=30});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: Colors.grey..withOpacity(0.5), // 그림자 색상
            offset: const Offset(4, 4), // x, y 방향으로 이동 (오른쪽 아래)
            blurRadius: 6, // 흐림 정도
            spreadRadius: 1, // 퍼짐 정도
          ),
        ],
      ),
      width: size,
      height: size,
      child: Center(
        child: Text('$number', style: TextStyles.bold20),
      ),
    );
  }
}
