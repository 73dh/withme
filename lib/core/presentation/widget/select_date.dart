import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';

Future<DateTime?> selectDate(BuildContext context, {DateTime? initial}) {
  final DateTime today = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? today,
    firstDate: DateTime(1920),
    lastDate: DateTime(2050),
    locale: const Locale('ko'),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: ColorStyles.activeButtonColor,
            onPrimary: Colors.black87,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IntrinsicHeight(
                    // 핵심: 내부 높이에 맞춤
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
