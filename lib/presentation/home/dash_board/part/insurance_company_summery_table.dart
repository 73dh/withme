import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';
import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

class InsuranceCompanySummaryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> customers;
  final TextStyle? textStyle;
  final Color? cellColor;

  const InsuranceCompanySummaryTable({
    super.key,
    required this.cellWidth,
    required this.customers,
    this.textStyle,
    this.cellColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Map<String, _InsuranceCompanyStats> statsMap = {};

    for (final customer in customers) {
      final Set<String> companiesThisCustomer = {};

      for (final policy in customer.policies) {
        final company = policy.insuranceCompany;

        statsMap.putIfAbsent(company, () => _InsuranceCompanyStats());
        statsMap[company]!.contractCount += 1;

        companiesThisCustomer.add(company);
      }

      for (final company in companiesThisCustomer) {
        statsMap[company]!.customerCount += 1;
      }
    }

    final sortedKeys = statsMap.keys.toList()..sort();

    // 제목행 색상은 CustomSummeryTable 스타일
    final headerColor = colorScheme.primaryContainer;
    final headerTextStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    // 데이터행 색상
    final rowColor = colorScheme.surface.withValues(alpha: 0.8);
    final defaultTextStyle = textStyle ?? theme.textTheme.bodyMedium;

    final List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: headerColor),
        children: [
          RenderTableCellText('보험사', isHeader: true, style: headerTextStyle),
          RenderTableCellText('고객 수', isHeader: true, style: headerTextStyle),
          RenderTableCellText('계약 건수', isHeader: true, style: headerTextStyle),
        ],
      ),
    ];

    if (sortedKeys.isEmpty) {
      rows.add(
        TableRow(
          decoration: BoxDecoration(color: rowColor),
          children: [
            RenderTableCellText('해당건 없음', style: defaultTextStyle),
            RenderTableCellText('', style: defaultTextStyle),
            RenderTableCellText('', style: defaultTextStyle),
          ],
        ),
      );
    } else {
      for (final company in sortedKeys) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(color: rowColor),
            children: [
              RenderTableCellText(company, style: defaultTextStyle),
              RenderTableCellText('${statsMap[company]!.customerCount}명', style: defaultTextStyle),
              RenderTableCellText('${statsMap[company]!.contractCount}건', style: defaultTextStyle),
            ],
          ),
        );
      }
    }

    return RenderTable(
      columnWidths: {
        0: FixedColumnWidth(cellWidth * 1.5),
        1: FixedColumnWidth(cellWidth),
        2: FixedColumnWidth(cellWidth),
      },
      tableRows: rows,
    );
  }
}

class _InsuranceCompanyStats {
  int customerCount = 0;
  int contractCount = 0;
}


