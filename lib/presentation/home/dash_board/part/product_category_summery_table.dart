import 'package:flutter/material.dart';
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
        if (category == null || category.trim().isEmpty) continue;

        // 계약 건수
        categoryStats.putIfAbsent(category, () => _CategoryStats());
        categoryStats[category]!.contractCount += 1;

        // 고객 수 중복 제거용
        categoriesPerCustomer.add(category);
      }

      // 고객 수는 중복 제거 후 카운트
      for (final category in categoriesPerCustomer) {
        categoryStats[category]!.customerCount += 1;
      }
    }

    final sortedKeys = categoryStats.keys.toList()..sort();

    return RenderTable(
      columnWidths: {
        0: FixedColumnWidth(cellWidth * 1.5),
        1: FixedColumnWidth(cellWidth),
        2: FixedColumnWidth(cellWidth),
      },
      tableRows: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blue.shade50),
          children: const [
            RenderTableCellText('상품 카테고리', isHeader: true),
            RenderTableCellText('고객 수', isHeader: true),
            RenderTableCellText('계약 건수', isHeader: true),
          ],
        ),
        for (final category in sortedKeys)
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              RenderTableCellText(category),
              RenderTableCellText('${categoryStats[category]!.customerCount}명'),
              RenderTableCellText('${categoryStats[category]!.contractCount}건'),
            ],
          ),
      ],
    );
  }
}

class _CategoryStats {
  int customerCount = 0;
  int contractCount = 0;
}
