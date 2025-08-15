import 'package:flutter/material.dart';

import '../../../../core/ui/core_ui_import.dart';

import 'package:flutter/material.dart';

import '../../../../core/ui/core_ui_import.dart';

class RenderTableCellText extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool? isBarProspect;
  final bool? isBarContract;
  final TextStyle? style; // ← 새로 추가

  const RenderTableCellText(
      this.text, {
        super.key,
        this.isHeader = false,
        this.isBarProspect,
        this.isBarContract,
        this.style, // ← 외부 스타일 지정 가능
      });

  @override
  Widget build(BuildContext context) {
    final defaultColor = isBarProspect == true
        ? ColorStyles.barChartProspectColor
        : isBarContract == true
        ? ColorStyles.barChartContractColor
        : Colors.black87;

    final defaultStyle = TextStyle(
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
        style: style ?? defaultStyle, // 전달받은 style 우선, 없으면 defaultStyle
      ),
    );
  }
}
