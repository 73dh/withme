import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

class BlinkingDots extends StatefulWidget {
  const BlinkingDots({super.key});

  @override
  State<BlinkingDots> createState() => _BlinkingDotsState();
}

class _BlinkingDotsState extends State<BlinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              width(6),
              Text(
                '당월 미관리',
                style: TextStyles.normal9.copyWith(color: Colors.redAccent),
              ),
            ],
          ),
        );
      },
    );
  }
}
