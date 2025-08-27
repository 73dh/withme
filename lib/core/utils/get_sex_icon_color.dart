import 'package:flutter/material.dart';

import '../ui/core_ui_import.dart';

Color getSexIconColor(String? sex, ColorScheme scheme) {
  switch (sex) {
    case '남':
      return ColorStyles.manColor;
    case '여':
      return ColorStyles.womanColor;
    default:
      return scheme.onSurfaceVariant;
  }
}
