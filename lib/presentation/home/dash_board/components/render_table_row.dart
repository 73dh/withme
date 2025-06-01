import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';

TableRow renderTableRow  ({
required List<String> cells,
 bool? isHeader=false}){
  return  TableRow(
      children:
      cells.map((text) {
        return Container(
          height: 44,
          alignment: Alignment.center,
          color: isHeader==false ? Colors.blue.shade50 : null,
          child: RenderTableCellText(text, isHeader: isHeader!),
        );
      }).toList(),
    );

}

