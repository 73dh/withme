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

class ProductCategorySummaryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> customers;
  final TextStyle? textStyle;
  final Color? cellColor;

  const ProductCategorySummaryTable({
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

    final Map<String, _CategoryStats> categoryStats = {};

    for (final customer in customers) {
      final Set<String> categoriesPerCustomer = {};

      for (final policy in customer.policies) {
        final category = policy.productCategory.trim();
        if (category.isEmpty) continue;

        categoryStats.putIfAbsent(category, () => _CategoryStats());
        categoryStats[category]!.contractCount += 1;

        categoriesPerCustomer.add(category);
      }

      for (final category in categoriesPerCustomer) {
        categoryStats[category]!.customerCount += 1;
      }
    }

    final sortedKeys = categoryStats.keys.toList()..sort();

    // 헤더 스타일 (InsuranceCompanySummaryTable과 동일)
    final headerColor = colorScheme.primaryContainer;
    final headerTextStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    // 데이터 행 스타일
    final rowColor = colorScheme.surface.withValues(alpha: 0.8);
    final defaultTextStyle = textStyle ?? theme.textTheme.bodyMedium;

    final List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: headerColor),
        children: [
          RenderTableCellText('상품 카테고리', isHeader: true, style: headerTextStyle),
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
      for (final category in sortedKeys) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(color: rowColor),
            children: [
              RenderTableCellText(category, style: defaultTextStyle),
              RenderTableCellText('${categoryStats[category]!.customerCount}명', style: defaultTextStyle),
              RenderTableCellText('${categoryStats[category]!.contractCount}건', style: defaultTextStyle),
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

class _CategoryStats {
  int customerCount = 0;
  int contractCount = 0;
}




