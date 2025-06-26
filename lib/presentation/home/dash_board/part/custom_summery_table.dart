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

  const CustomSummeryTable({
    super.key,
    required this.cellWidth,
    required this.total,
    required this.prospect,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    return RenderTable(
      columnWidths: {
        for (int i = 0; i < 5; i++) i: FixedColumnWidth(cellWidth),
      },
      tableRows: [
        TableRow(
          decoration: BoxDecoration(color: ColorStyles.tableHeadColor),
          children: const [
            RenderTableCellText('구분', isHeader: true),
            RenderTableCellText('전체 (Total)', isHeader: true),
            RenderTableCellText('가망 고객 (Prospect)', isHeader: true),
            RenderTableCellText('계약자 (Customer)', isHeader: true),
            RenderTableCellText('총 계약건수', isHeader: true),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const RenderTableCellText('고객/건'),
            RenderTableCellText('${total.length}명'),
            RenderTableCellText('${prospect.length}명'),
            RenderTableCellText('${contract.length}명'),
            RenderTableCellText(
              '${total.map((c) => c.policies.length).fold(0, (a, b) => a + b)}건',
            ),
          ],
        ),
      ],
    );;
  }
}
