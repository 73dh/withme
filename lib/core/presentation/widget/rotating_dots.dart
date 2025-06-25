import 'dart:math';

import '../core_presentation_import.dart';

class RotatingDots extends StatefulWidget {
  final double size;
  final double dotBaseSize;
  final double dotPulseRange;
  final Duration speed;
  final List<Color> colors;

  const RotatingDots({
    super.key,
    this.size = 40,
    this.dotBaseSize = 6,
    this.dotPulseRange = 3,
    this.speed = const Duration(milliseconds: 3000),
    this.colors = const [Colors.red, Colors.blue],
  });

  @override
  State<RotatingDots> createState() => _RotatingPulsingDotsState();
}

class _RotatingPulsingDotsState extends State<RotatingDots>
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
    final radius = widget.size / 2 - widget.dotBaseSize;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * 2 * pi;

          return Stack(
            children: List.generate(2, (i) {
              final double offsetAngle = angle + (pi * i); // 0, pi (정반대 위치)
              final double pulse = sin(_controller.value * 2 * pi + i * pi);
              final double size = widget.dotBaseSize +
                  widget.dotPulseRange * (pulse * 0.5 + 0.5);

              final Offset center = Offset(widget.size / 2, widget.size / 2);
              final Offset dotOffset = Offset(
                center.dx + radius * cos(offsetAngle),
                center.dy + radius * sin(offsetAngle),
              );

              return Positioned(
                left: dotOffset.dx - size / 2,
                top: dotOffset.dy - size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.colors[i % widget.colors.length],
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
