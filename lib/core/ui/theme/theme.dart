import 'package:flutter/material.dart';

import '../text_style/text_styles.dart';

final theme=ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyles.bold20.copyWith(
      fontStyle: FontStyle.italic,
      color: Colors.black38,
    ),
  ),
  bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey.shade100),
  floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor:  Colors.grey.shade200,shape:CircleBorder() ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.transparent,elevation: 0
  ),
);