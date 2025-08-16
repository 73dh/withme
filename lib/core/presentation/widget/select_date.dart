import 'package:flutter/material.dart';
import '../../ui/core_ui_import.dart';

Future<DateTime?> selectDate(BuildContext context, {DateTime? initial}) {
  final DateTime today = DateTime.now();
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

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
            primary: ColorStyles.activeButtonColor, // 포커스 색상만 override
            onPrimary: Colors.white,                // 버튼 텍스트 색
            onSurface: colorScheme.onSurface,       // 일반 텍스트 색
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              textStyle: textTheme.labelLarge,
            ),
          ),
        ),
        child: Builder(
          builder: (context) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380, // 최대 너비 제한 (선택)
                ),
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IntrinsicHeight(
                    // 내부 높이에 맞춰 다이얼로그 크기 조정
                    child: child!,
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
