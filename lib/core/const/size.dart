import 'package:flutter/material.dart';

abstract interface class AppSizes {
  static final deviceSize =
      MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.single,
      ).size;

  static final double myMenuWidth = deviceSize.width * 2 / 3;
  static final double bottomNavIconSize = 30;

  static double toggleMinWidth = 50; // 공통 너비
}
