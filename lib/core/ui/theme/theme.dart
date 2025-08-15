import 'package:flutter/material.dart';
import 'package:withme/core/ui/color/color_style.dart';

import '../text_style/text_styles.dart';

import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme:  AppBarTheme(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.black38,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: Colors.black38,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
  floatingActionButtonTheme:  FloatingActionButtonThemeData(
    backgroundColor: ColorStyles.fabColor, // FAB 색상 직접 지정
    shape: CircleBorder(),
  ),
  textTheme: const TextTheme(
    // 📢 Display - 가장 큰 제목
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),

    // 📰 Headline - 큰 헤드라인
    headlineLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    headlineMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    headlineSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),

    // 🏷 Title - 제목·서브타이틀
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),

    // 📖 Body - 본문
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),

    // 🏷 Label - 버튼·태그·설명
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  // 다크 모드 배경
  appBarTheme: const AppBarTheme(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Color(0xFF1E1E1E), // 다크 모드 앱바 색
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: Colors.white70,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
  floatingActionButtonTheme:  FloatingActionButtonThemeData(
    backgroundColor: ColorStyles.fabColor, // FAB 색상 직접 지정
    shape: CircleBorder(),
  ),
  textTheme: const TextTheme(
    // 📢 Display - 가장 큰 제목
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),

    // 📰 Headline - 큰 헤드라인
    headlineLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    headlineMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    headlineSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),

    // 🏷 Title - 제목·서브타이틀
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),

    // 📖 Body - 본문
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),

    // 🏷 Label - 버튼·태그·설명
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
  ),
);

extension ColorSchemeX on ColorScheme {
  Color get onSurface38 => onSurface.withValues(alpha: 0.38);
  Color get onSurface12=> onSurface.withValues(alpha: 0.12);
  Color get onSurface60 => onSurface.withValues(alpha: 0.6);
  Color get onSurface80 => onSurface.withValues(alpha: 0.8);
}