import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

class ProductCategorySummaryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> customers;

  const ProductCategorySummaryTable({
    super.key,
    required this.cellWidth,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, _CategoryStats> categoryStats = {};

    for (final customer in customers) {
      final Set<String> categoriesPerCustomer = {};

      for (final policy in customer.policies) {
        final category = policy.productCategory;
        if (category.trim().isEmpty) continue;

        categoryStats.putIfAbsent(category, () => _CategoryStats());
        categoryStats[category]!.contractCount += 1;

        categoriesPerCustomer.add(category);
      }

      for (final category in categoriesPerCustomer) {
        categoryStats[category]!.customerCount += 1;
      }
    }

    final sortedKeys = categoryStats.keys.toList()..sort();

    final List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: ColorStyles.tableHeadColor),
        children: const [
          RenderTableCellText('상품 카테고리', isHeader: true),
          RenderTableCellText('고객 수', isHeader: true),
          RenderTableCellText('계약 건수', isHeader: true),
        ],
      ),
    ];

    if (sortedKeys.isEmpty) {
      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            RenderTableCellText('해당건 없음'),
            RenderTableCellText(''),
            RenderTableCellText(''),
          ],
        ),
      );
    } else {
      for (final category in sortedKeys) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              RenderTableCellText(category),
              RenderTableCellText('${categoryStats[category]!.customerCount}명'),
              RenderTableCellText('${categoryStats[category]!.contractCount}건'),
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
