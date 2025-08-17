import 'package:flutter/material.dart';

import '../../../../core/ui/core_ui_import.dart';

import 'package:flutter/material.dart';

import '../../../../core/ui/core_ui_import.dart';
import 'package:flutter/material.dart';

class RenderTableCellText extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool? isBarProspect;
  final bool? isBarContract;
  final TextStyle? style; // 외부 스타일 지정 가능

  const RenderTableCellText(
      this.text, {
        super.key,
        this.isHeader = false,
        this.isBarProspect,
        this.isBarContract,
        this.style,
      });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 상태별 기본 색상 결정
    final Color defaultColor = isBarProspect == true
        ? colorScheme.primary   // 가망고객 색상
        : isBarContract == true
        ? colorScheme.secondary // 계약고객 색상
        : colorScheme.onSurface; // 일반 텍스트

    final TextStyle defaultStyle = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 11,
      color: defaultColor,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style ?? defaultStyle, // 외부 스타일 우선
      ),
    );
  }
}
