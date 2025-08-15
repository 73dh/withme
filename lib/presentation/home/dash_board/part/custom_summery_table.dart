import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';

import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';

import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';

import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';

class CustomSummeryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> total;
  final List<CustomerModel> prospect;
  final List<CustomerModel> contract;

  // 추가: 텍스트 스타일과 셀 색상 외부에서 전달 가능
  final TextStyle? textStyle;
  final Color? cellColor;
  final Color? headerColor;
  final TextStyle? headerTextStyle;

  const CustomSummeryTable({
    super.key,
    required this.cellWidth,
    required this.total,
    required this.prospect,
    required this.contract,
    this.textStyle,
    this.cellColor,
    this.headerColor,
    this.headerTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = textStyle ?? theme.textTheme.bodyMedium;
    final defaultCellColor = cellColor ?? theme.colorScheme.surfaceVariant;
    final defaultHeaderColor = headerColor ?? theme.colorScheme.primaryContainer;
    final defaultHeaderTextStyle = headerTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          // fontWeight: FontWeight.bold,
        );

    return RenderTable(
      columnWidths: {for (int i = 0; i < 5; i++) i: FixedColumnWidth(cellWidth)},
      tableRows: [
        // 헤더
        TableRow(
          decoration: BoxDecoration(color: defaultHeaderColor),
          children: [
            RenderTableCellText('구분', isHeader: true, style: defaultHeaderTextStyle),
            RenderTableCellText('전체', isHeader: true, style: defaultHeaderTextStyle),
            RenderTableCellText('가망고객', isHeader: true, style: defaultHeaderTextStyle),
            RenderTableCellText('계약자', isHeader: true, style: defaultHeaderTextStyle),
            RenderTableCellText('총계약', isHeader: true, style: defaultHeaderTextStyle),
          ],
        ),
        // 데이터 행
        TableRow(
          decoration: BoxDecoration(color: defaultCellColor),
          children: [
            RenderTableCellText('고객/건', style: defaultTextStyle),
            RenderTableCellText('${total.length}명', style: defaultTextStyle),
            RenderTableCellText('${prospect.length}명', style: defaultTextStyle),
            RenderTableCellText('${contract.length}명', style: defaultTextStyle),
            RenderTableCellText(
              '${total.map((c) => c.policies.length).fold(0, (a, b) => a + b)}건',
              style: defaultTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}
