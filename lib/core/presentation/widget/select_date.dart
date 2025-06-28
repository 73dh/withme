import 'package:flutter/material.dart';

Future<DateTime?> selectDate(BuildContext context) {
  return showDatePicker(
    context: context,
    locale: const Locale('ko'),
    firstDate: DateTime(1920),
    lastDate: DateTime(2050),
  );
}
