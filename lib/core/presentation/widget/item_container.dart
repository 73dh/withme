import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import 'package:flutter/material.dart';

class ItemContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color? backgroundColor;

  const ItemContainer({
    super.key,
    required this.child,
    this.height = 86,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface, // 배경색 ColorScheme 사용
        // borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.3), // 그림자 색상 ColorScheme 사용
            offset: const Offset(3, 3),
            blurRadius: 6,
            spreadRadius: 1,
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
