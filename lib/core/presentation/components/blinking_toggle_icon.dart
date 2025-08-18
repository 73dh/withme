import 'package:flutter/material.dart';

import '../core_presentation_import.dart';

class BlinkingToggleIcon extends StatefulWidget {
  final bool expanded;
  final VoidCallback onTap;
  final Color? color; // 추가

  const BlinkingToggleIcon({
    super.key,
    required this.expanded,
    required this.onTap,
    this.color, // 추가
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
    )..repeat(reverse: true);

    _animation = Tween<double>(
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _animation,
        child: Icon(
          widget.expanded
              ? Icons.keyboard_double_arrow_up
              : Icons.keyboard_double_arrow_down,
          size: 25,
          color: widget.color ?? colorScheme.primary, // color 사용
        ),
      ),
    );
  }
}
