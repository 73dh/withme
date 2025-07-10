import 'dart:math';

import '../core_presentation_import.dart';

class OrbitingDots extends StatefulWidget {
  final int dotCount;
  final double radius;
  final double dotSize;
  final Duration speed;
  final Color color;

  const OrbitingDots({
    super.key,
    this.dotCount = 5,
    this.radius = 5,
    this.dotSize = 3,
    this.speed = const Duration(seconds: 5),
    this.color = Colors.redAccent,
  });

  @override
  State<OrbitingDots> createState() => _OrbitingDotsState();
}

class _OrbitingDotsState extends State<OrbitingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius * 2 + widget.dotSize,
      height: widget.radius * 2 + widget.dotSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final double baseAngle = _controller.value * 2 * pi;

          return Stack(
            children: List.generate(widget.dotCount, (i) {
              final angle = baseAngle + (i * 2 * pi / widget.dotCount);
              final offset = Offset(
                widget.radius * cos(angle),
                widget.radius * sin(angle),
              );

              return Positioned(
                left: widget.radius + offset.dx,
                top: widget.radius + offset.dy,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
