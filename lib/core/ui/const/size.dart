import 'package:flutter/material.dart';

abstract interface class AppSizes {
  static final deviceSize =
      MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.single,
      ).size;

  static final double myMenuWidth = deviceSize.width * 2 / 3;
}
