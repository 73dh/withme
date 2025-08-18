import 'package:flutter/material.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../domain/domain_import.dart';
import '../../../../domain/model/customer_model.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

class CustomSummeryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> total;
  final List<CustomerModel> prospect;
  final List<CustomerModel> contract;

  final TextStyle? textStyle;

  const CustomSummeryTable({
    super.key,
    required this.cellWidth,
    required this.total,
    required this.prospect,
    required this.contract,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 제목행 색상
    final headerColor = colorScheme.primaryContainer;
    final headerTextStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    // 데이터행 색상
    final rowColor = colorScheme.surface.withValues(alpha: 0.8);
    final defaultTextStyle =
        textStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface);

    return RenderTable(
      columnWidths: {
        for (int i = 0; i < 5; i++) i: FixedColumnWidth(cellWidth),
      },
      tableRows: [
        // 헤더 행
        TableRow(
          decoration: BoxDecoration(color: headerColor),
          children: [
            RenderTableCellText('구분', isHeader: true, style: headerTextStyle),
            RenderTableCellText('전체', isHeader: true, style: headerTextStyle),
            RenderTableCellText('가망고객', isHeader: true, style: headerTextStyle),
            RenderTableCellText('계약자', isHeader: true, style: headerTextStyle),
            RenderTableCellText('총계약', isHeader: true, style: headerTextStyle),
          ],
        ),
        // 데이터 행
        TableRow(
          decoration: BoxDecoration(color: rowColor),
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
