import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class AnimatedFabContainer extends StatefulWidget {
  final bool fabVisibleLocal;
  final Widget child;
  final double? rightPosition;
  final double? bottomPosition;

  const AnimatedFabContainer({
    super.key,
    required this.fabVisibleLocal,
    required this.child,
    required this.rightPosition,
    required this.bottomPosition,
  });

  @override
  State<AnimatedFabContainer> createState() => _AnimatedFabContainerState();
}

class _AnimatedFabContainerState extends State<AnimatedFabContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.duration300,
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.fabVisibleLocal) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFabContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fabVisibleLocal) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.rightPosition,
      bottom: widget.bottomPosition,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
