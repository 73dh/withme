import 'package:flutter/material.dart';

import '../core_presentation_import.dart';

class BlinkingCursorIcon extends StatefulWidget {
  final IconData icon; // 깜빡일 아이콘 (예: Icons.edit, Icons.text_fields)
  final double size; // 아이콘 크기
  final Color color; // 아이콘 색상
  final Duration blinkSpeed; // 깜빡이는 속도

  const BlinkingCursorIcon({
    super.key,
    this.icon = Icons.edit_note_rounded, // 기본값은 '편집' 아이콘
    this.size = 25.0,
    this.color = Colors.blueAccent,
    this.blinkSpeed = const Duration(milliseconds: 700), // 0.7초마다 깜빡임
  });

  @override
  State<BlinkingCursorIcon> createState() => _BlinkingCursorIconState();
}

class _BlinkingCursorIconState extends State<BlinkingCursorIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.blinkSpeed)
      ..repeat(reverse: true); // 나타났다 사라졌다 반복 (reverse: true 중요)

    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Icon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}

