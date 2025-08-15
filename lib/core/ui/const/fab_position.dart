import '../../presentation/core_presentation_import.dart';

abstract interface class FabPosition {
  static double get topFabBottomHeight => kBottomNavigationBarHeight*3+10;
  static double get bottomFabBottomHeight =>
      kBottomNavigationBarHeight*2 ;
}
