import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class PartBox extends StatelessWidget {
  final Widget child;
  final Color? color;

  const PartBox({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface, // Theme 기반 배경
        border: Border.all(
          color: colorScheme.outline, // Theme 기반 테두리
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.25), // Theme 그림자 색
            offset: const Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
