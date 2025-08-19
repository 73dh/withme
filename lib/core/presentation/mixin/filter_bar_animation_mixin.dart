import '../core_presentation_import.dart';
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

  /// 단순히 애니메이션만 제어
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

  /// 자동 제어용: 강제로 열기/닫기
  void setFilterBarExpanded(bool expanded) {
    setState(() {
      filterBarExpanded = expanded;
      if (filterBarExpanded) {
        filterBarController.forward();
      } else {
        filterBarController.reverse();
      }
    });
  }
}

//
// mixin FilterBarAnimationMixin<T extends StatefulWidget> on State<T> {
//   late final AnimationController filterBarController;
//   late final Animation<double> heightFactor;
//   bool filterBarExpanded = false;
//
//   void initFilterBarAnimation({required TickerProvider vsync}) {
//     filterBarController = AnimationController(
//       vsync: vsync,
//       duration: const Duration(milliseconds: 300),
//       value: 0.0,
//     );
//
//     heightFactor = CurvedAnimation(
//       parent: filterBarController,
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void disposeFilterBarAnimation() {
//     filterBarController.dispose();
//   }
//
//   void toggleFilterBarAnimation() {
//     setState(() {
//       filterBarExpanded = !filterBarExpanded;
//       if (filterBarExpanded) {
//         filterBarController.forward();
//       } else {
//         filterBarController.reverse();
//       }
//     });
//   }
// }
//
