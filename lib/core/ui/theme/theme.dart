import 'package:flutter/material.dart';
import 'package:withme/core/ui/color/color_style.dart';

import '../text_style/text_styles.dart';


import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
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
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white,elevation: 0,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor:ColorStyles.fabColor,
    shape: const CircleBorder(),
  ),
    textTheme: TextTheme(
      displayLarge: TextStyles.bold20.copyWith(color: Colors.black87),
      displayMedium: TextStyles.bold16.copyWith(color: Colors.black87),
      displaySmall: TextStyles.bold14.copyWith(color: Colors.black87),

      headlineLarge: TextStyles.bold16.copyWith(color: Colors.black87),
      headlineMedium: TextStyles.bold14.copyWith(color: Colors.black87),
      headlineSmall: TextStyles.bold12.copyWith(color: Colors.black87),

      titleLarge: TextStyles.subTitle.copyWith(color: Colors.black87),
      titleMedium: TextStyles.normal14.copyWith(color: Colors.black87),
      titleSmall: TextStyles.normal12.copyWith(color: Colors.black87),

      bodyLarge: TextStyles.normal14.copyWith(color: Colors.black87),
      bodyMedium: TextStyles.normal12.copyWith(color: Colors.black54),
      bodySmall: TextStyles.caption.copyWith(color: Colors.grey),

      labelLarge: TextStyles.bold14.copyWith(color: Colors.black87),
      labelMedium: TextStyles.normal12.copyWith(color: Colors.black54),
      labelSmall: TextStyles.normal10.copyWith(color: Colors.black54),
    )
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.black87,
    titleTextStyle: TextStyles.bold20.copyWith(
      fontStyle: FontStyle.italic,
      color: Colors.white70, // 밝은 글씨로 변경
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black87,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ColorStyles.fabColor, // 다크모드에 맞는 색상으로 조정 가능
    shape: const CircleBorder(),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyles.bold20.copyWith(color: Colors.white70),
    displayMedium: TextStyles.bold16.copyWith(color: Colors.white70),
    displaySmall: TextStyles.bold14.copyWith(color: Colors.white70),

    headlineLarge: TextStyles.bold16.copyWith(color: Colors.white70),
    headlineMedium: TextStyles.bold14.copyWith(color: Colors.white70),
    headlineSmall: TextStyles.bold12.copyWith(color: Colors.white70),

    titleLarge: TextStyles.subTitle.copyWith(color: Colors.white70),
    titleMedium: TextStyles.normal14.copyWith(color: Colors.white70),
    titleSmall: TextStyles.normal12.copyWith(color: Colors.white70),

    bodyLarge: TextStyles.normal14.copyWith(color: Colors.white70),
    bodyMedium: TextStyles.normal12.copyWith(color: Colors.white60),
    bodySmall: TextStyles.caption.copyWith(color: Colors.grey.shade400),

    labelLarge: TextStyles.bold14.copyWith(color: Colors.white70),
    labelMedium: TextStyles.normal12.copyWith(color: Colors.white70),
    labelSmall: TextStyles.normal10.copyWith(color: Colors.white70),
  )
);



