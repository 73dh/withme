import 'package:flutter/material.dart';

Future<DateTime?> selectDate(BuildContext context, {DateTime? initial}) {
  final DateTime today = DateTime.now();
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  // 다크/라이트 대비 색 지정
  final textColor = isDark ? Colors.white : Colors.black87;
  final hintColor = isDark ? Colors.white70 : Colors.black54;

  return showDatePicker(
    context: context,
    initialDate: initial ?? today,
    firstDate: DateTime(1920),
    lastDate: DateTime(2050),
    locale: const Locale('ko'),
    builder: (context, child) {
      return Theme(
        data: theme.copyWith(
          colorScheme: colorScheme.copyWith(
            primary: colorScheme.primary, // 선택/포커스 색
            onPrimary: Colors.white, // 선택된 날짜 글자
            surface: colorScheme.surface, // 다이얼로그 배경
            onSurface: textColor, // 일반 텍스트, 입력 글자
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary, // 확인/취소 버튼
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: hintColor),
            labelStyle: TextStyle(color: textColor),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: colorScheme.primary,
            selectionColor: colorScheme.primary.withValues(alpha: 0.3),
            selectionHandleColor: colorScheme.primary,
          ),
          textTheme: theme.textTheme.apply(
            bodyColor: textColor,
            displayColor: textColor,
          ),
        ),
        child: Builder(
          builder: (context) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IntrinsicHeight(child: child!),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
