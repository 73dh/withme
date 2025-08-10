import 'package:flutter/material.dart';

import '../../ui/color/color_style.dart';
import '../core_presentation_import.dart';

class BlinkingToggleIcon extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;

  const BlinkingToggleIcon({
    super.key,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<BlinkingToggleIcon> createState() => _BlinkingToggleIconState();
}

class _BlinkingToggleIconState extends State<BlinkingToggleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // 깜빡임 반복

    _animation = Tween(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _animation,
        child: Icon(
          widget.expanded
              ? Icons
                  .keyboard_double_arrow_up // 펼친 상태: 위쪽 화살표
              : Icons.keyboard_double_arrow_down, // 접힌 상태: 아래쪽 화살표
          size: 25,
          color: ColorStyles.activeSwitchColor,
        ),
      ),
    );
  }
}
