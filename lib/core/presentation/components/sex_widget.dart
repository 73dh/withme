import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';


import 'package:flutter/material.dart';
import '../../ui/core_ui_import.dart';
import 'package:flutter/material.dart';
import '../../ui/core_ui_import.dart';

/// 성별 색상 세트 (통일성 유지)
class SexColors {
  final Color icon;
  final Color background;

  const SexColors({
    required this.icon,
    required this.background,
  });

  static SexColors fromSex(String? sex, ColorScheme scheme) {
    switch (sex) {
      case '남':
        return SexColors(
          icon:ColorStyles.manColor,
          // icon: scheme.primary,
          background: scheme.primaryContainer.withValues(alpha: 0.3),
        );
      case '여':
        return SexColors(
          icon: ColorStyles.womanColor,
          background: scheme.secondaryContainer.withValues(alpha: 0.3),
        );
      default:
        return SexColors(
          icon: scheme.onSurfaceVariant,
          background: scheme.surfaceVariant,
        );
    }
  }
}

/// 성별 아이콘 반환
Widget sexIcon(String sex, ColorScheme colorScheme) {
  final colors = SexColors.fromSex(sex, colorScheme);
  return Image.asset(
    sex == '남' ? IconsPath.manIcon : IconsPath.womanIcon,
    width: 15,
    color: colors.icon,
  );
}

/// 성별 배경색 반환
Color getSexBackgroundColor(String? sex, ColorScheme colorScheme) =>
    SexColors.fromSex(sex, colorScheme).background;

/// 성별 아이콘 색상 반환
Color getSexIconColor(String? sex, ColorScheme colorScheme) =>
    SexColors.fromSex(sex, colorScheme).icon;
