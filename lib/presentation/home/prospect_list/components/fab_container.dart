import '../../../../core/presentation/core_presentation_import.dart';

class FabContainer extends StatelessWidget {
  final bool fabVisibleLocal;
  final Widget child;
  final double? rightPosition;
  final double? bottomPosition;

  const FabContainer({
    super.key,
    required this.fabVisibleLocal,
    required this.child,
   required  this.rightPosition,
   required  this.bottomPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: rightPosition,
      bottom: bottomPosition,
      child: AnimatedScale(
        scale: fabVisibleLocal ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: child,
      ),
    );
  }
}
