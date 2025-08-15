import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';


import 'package:flutter/material.dart';
import '../../ui/core_ui_import.dart';

/// 성별 아이콘 반환 (ColorScheme 기반)
Widget sexIcon(String sex, ColorScheme colorScheme) => switch (sex) {
  '남' => Image.asset(
    IconsPath.manIcon,
    width: 15,
    color: colorScheme.primary, // 남성 색상 → primary
  ),
  _ => Image.asset(
    IconsPath.womanIcon,
    width: 15,
    color: colorScheme.secondary, // 여성 색상 → secondary
  ),
};

/// 성별 배경색 반환 (ColorScheme 기반)
Color getSexBackgroundColor(String? sex, ColorScheme colorScheme) {
  switch (sex) {
    case '남':
      return colorScheme.primaryContainer.withOpacity(0.3); // 연한 파란색 계열
    case '여':
      return colorScheme.secondaryContainer.withOpacity(0.3); // 연한 분홍색 계열
    default:
      return colorScheme.surfaceVariant; // 기본 색
  }
}

/// 성별 아이콘 색상 반환 (ColorScheme 기반)
Color getSexIconColor(String? sex, ColorScheme colorScheme) {
  switch (sex) {
    case '남':
      return colorScheme.primary; // 남성 색상
    case '여':
      return colorScheme.secondary; // 여성 색상
    default:
      return colorScheme.onSurfaceVariant; // 기본 색
  }
}
