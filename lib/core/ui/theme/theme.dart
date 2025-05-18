import 'package:flutter/material.dart';
import 'package:withme/core/ui/color/color_style.dart';

import '../text_style/text_styles.dart';

final theme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.white,
    titleTextStyle: TextStyles.bold20.copyWith(
      fontStyle: FontStyle.italic,
      color: Colors.black38,
    ),
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: ColorStyles.bottomNavColor,
    elevation: 0,
    shape: const CircularNotchedRectangle(),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.amber.shade200,
    shape: const CircleBorder(),
  ),
);
