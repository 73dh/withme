import 'package:flutter/material.dart';

class PartBox extends StatelessWidget {
  final Widget child;
  final Color? color;

  const PartBox({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade500, width: 1.2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // 그림자 색상
            offset: const Offset(3, 3), // x, y 방향 으로 이동 (오른쪽 아래)
            blurRadius: 6, // 흐림 정도
            spreadRadius: 1, // 퍼짐 정도
          ),
        ],
      ),
      child: child,
    );
  }
}
