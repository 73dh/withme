import 'dart:math';
import 'package:flutter/material.dart';

class DataChaseIndicator extends StatefulWidget {
  final double size;
  final double dotSize;
  final int dotCount;
  final Duration duration;
  final List<Color> colors;

  const DataChaseIndicator({
    super.key,
    this.size = 20,
    this.dotSize = 6,
    this.dotCount = 6,
    this.duration = const Duration(milliseconds: 1200),
    this.colors = const [Colors.blue],
  });

  @override
  State<DataChaseIndicator> createState() => _DataChaseIndicatorState();
}

class _DataChaseIndicatorState extends State<DataChaseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    super.initState();
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
        builder: (_, __) {
          return CustomPaint(
            painter: _ChasePainter(
              progress: _controller.value,
              dotCount: widget.dotCount,
              radius: widget.size / 2 - widget.dotSize,
              dotSize: widget.dotSize,
              colors: widget.colors,
            ),
          );
        },
      ),
    );
  }
}

class _ChasePainter extends CustomPainter {
  final double progress;
  final int dotCount;
  final double radius;
  final double dotSize;
  final List<Color> colors;

  _ChasePainter({
    required this.progress,
    required this.dotCount,
    required this.radius,
    required this.dotSize,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    for (int i = 0; i < dotCount; i++) {
      // 각 점의 위치를 시간차를 두고 회전
      final double angle = 2 * pi * ((i / dotCount + progress) % 1);
      final Offset offset = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // 선두일수록 크기 큼 (추격 느낌)
      final double distanceToHead = (i / dotCount + progress) % 1;
      final double scale = 0.5 + 0.5 * (1 - distanceToHead); // 0.5 ~ 1.0
      final double currentSize = dotSize * scale;

      final Paint paint = Paint()
        ..color = colors[i % colors.length];

      canvas.drawCircle(offset, currentSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChasePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
