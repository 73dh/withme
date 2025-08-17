import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';

TableRow renderTableRow({
  required List<String> cells,
  bool isHeader = false,
  Color? backgroundColor,
  bool? isBarProspect,
  bool? isBarContract,
  TextStyle? textStyle,
}) {
  return TableRow(
    children: cells.map((text) {
      return Container(
        decoration: BoxDecoration(color: backgroundColor),
        height: 46,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4), // 여백 확보
        child: FittedBox(
          fit: BoxFit.scaleDown, // 텍스트가 영역에 맞게 축소
          child: RenderTableCellText(
            text,
            isHeader: isHeader,
            isBarProspect: isBarProspect,
            isBarContract: isBarContract,
            style: textStyle,
          ),
        ),
      );
    }).toList(),
  );
}
