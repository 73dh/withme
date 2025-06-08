import 'package:flutter/material.dart';

import '../../ui/core_ui_import.dart';


Widget sexIcon(String sex) => switch (sex) {
  '남' => Image.asset(IconsPath.manIcon, width: 15,color: Colors.blueAccent,),
  _ => Image.asset(IconsPath.womanIcon, width: 15,color: Colors.redAccent,),
};

Color getSexBackgroundColor(String? sex) {
  switch (sex) {
    case '남':
      return const Color(0xFFD0E8FF); // 연한 파란색
    case '여':
      return const Color(0xFFFFE0E6); // 연한 분홍색
    default:
      return ColorStyles.customerItemColor; // 기본 색
  }
}