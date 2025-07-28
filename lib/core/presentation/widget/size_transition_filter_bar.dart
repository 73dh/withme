import '../core_presentation_import.dart';

class SizeTransitionFilterBar extends StatelessWidget {
  final Animation<double> heightFactor;
  final Widget child;

  const SizeTransitionFilterBar({
    super.key,
    required this.heightFactor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: heightFactor,
        axisAlignment: -1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ),
    );
  }
}
