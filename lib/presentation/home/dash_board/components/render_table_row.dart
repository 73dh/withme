import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';

TableRow renderTableRow({
  required List<String> cells,
  bool isHeader = false,
  Color? backgroundColor,
  bool? isBarProspect,
  bool? isBarContract,
  TextStyle? textStyle, // ← 추가
}) {
  return TableRow(
    children: cells.map((text) {
      return Container(
        decoration: BoxDecoration(color: backgroundColor),
        height: 46,
        alignment: Alignment.center,
        child: RenderTableCellText(
          text,
          isHeader: isHeader,
          isBarProspect: isBarProspect,
          isBarContract: isBarContract,
          style: textStyle, // ← 적용
        ),
      );
    }).toList(),
  );
}
