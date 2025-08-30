import 'package:flutter/material.dart';

import '../core_presentation_import.dart';

class ItemContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color? backgroundColor;

  const ItemContainer({
    super.key,
    required this.child,
    this.height = 80,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        backgroundColor ?? (isDark ? Colors.grey[900] : colorScheme.surface);

    // 그림자 색상과 위치
    final mainShadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.1);
    final subShadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.05);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // 아래쪽 + 우측 그림자 (주 그림자)
          BoxShadow(
            color: mainShadowColor,
            offset: const Offset(0, 2), // y: 아래쪽
            blurRadius: 6,
            spreadRadius: 0,
          ),
          // 살짝 확산 그림자 (우측 강조)
          BoxShadow(
            color: subShadowColor,
            offset: const Offset(2, 2), // x: 우측, y: 아래쪽
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: child,
      ),
    );
  }
}
