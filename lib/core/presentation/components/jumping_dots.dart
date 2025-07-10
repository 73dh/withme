import '../core_presentation_import.dart';

class JumpingDots extends StatefulWidget {
  const JumpingDots({super.key});

  @override
  State<JumpingDots> createState() => _JumpingDotRowState();
}

class _JumpingDotRowState extends State<JumpingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();

    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_animations.length, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
