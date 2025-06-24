import 'dart:math';
import 'package:flutter/material.dart';

class MyCircularIndicator extends StatefulWidget {
  final double size;
  final double dotBaseSize;
  final double dotPulseRange; // 커졌다 작아지는 범위
  final Duration speed;
  final List<Color> colors;

  const MyCircularIndicator({
    super.key,
    this.size = 30,
    this.dotBaseSize = 6,
    this.dotPulseRange = 3,
    this.speed = const Duration(milliseconds: 1500),
    this.colors = const [Colors.red, Colors.green, Colors.blue],
  });

  @override
  State<MyCircularIndicator> createState() =>
      _MyCircularIndicatorState();
}

class _MyCircularIndicatorState extends State<MyCircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.speed)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ThreeDotsPainter(
              angle: _controller.value * 2 * pi,
              radius: widget.size / 2 - widget.dotBaseSize,
              baseSize: widget.dotBaseSize,
              pulseRange: widget.dotPulseRange,
              colors: widget.colors,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _ThreeDotsPainter extends CustomPainter {
  final double angle;
  final double radius;
  final double baseSize;
  final double pulseRange;
  final List<Color> colors;
  final double progress;

  _ThreeDotsPainter({
    required this.angle,
    required this.radius,
    required this.baseSize,
    required this.pulseRange,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    for (int i = 0; i < 3; i++) {
      final double offsetAngle = angle + (2 * pi / 3) * i;

      // 부드러운 커졌다 작아졌다 효과 (위상차 부여)
      final double pulse = sin(progress * 2 * pi + (i * 2 * pi / 3));
      final double dotSize = baseSize + pulseRange * (pulse * 0.5 + 0.5); // 0 ~ 1 범위로 변환

      final Offset dotPosition = Offset(
        center.dx + radius * cos(offsetAngle),
        center.dy + radius * sin(offsetAngle),
      );

      final Paint dotPaint = Paint()..color = colors[i % colors.length];
      canvas.drawCircle(dotPosition, dotSize / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeDotsPainter oldDelegate) =>
      oldDelegate.angle != angle ||
          oldDelegate.progress != progress ||
          oldDelegate.colors != colors;
}
