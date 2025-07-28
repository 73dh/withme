import '../core_presentation_import.dart';

mixin FilterBarAnimationMixin<T extends StatefulWidget> on State<T> {
  late final AnimationController filterBarController;
  late final Animation<double> heightFactor;
  bool filterBarExpanded = false;

  void initFilterBarAnimation({required TickerProvider vsync}) {
    filterBarController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    heightFactor = CurvedAnimation(
      parent: filterBarController,
      curve: Curves.easeInOut,
    );
  }

  void disposeFilterBarAnimation() {
    filterBarController.dispose();
  }

  void toggleFilterBarAnimation() {
    setState(() {
      filterBarExpanded = !filterBarExpanded;
      if (filterBarExpanded) {
        filterBarController.forward();
      } else {
        filterBarController.reverse();
      }
    });
  }
}

