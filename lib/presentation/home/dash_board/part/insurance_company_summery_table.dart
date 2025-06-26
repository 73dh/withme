import 'package:flutter/material.dart';
import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';
import '../components/render_table.dart';
import '../components/render_table_cell_text.dart';

class InsuranceCompanySummaryTable extends StatelessWidget {
  final double cellWidth;
  final List<CustomerModel> customers;

  const InsuranceCompanySummaryTable({
    super.key,
    required this.cellWidth,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
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

    final List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: ColorStyles.tableHeadColor),
        children: const [
          RenderTableCellText('보험사', isHeader: true),
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
      for (final company in sortedKeys) {
        rows.add(
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              RenderTableCellText(company),
              RenderTableCellText('${statsMap[company]!.customerCount}명'),
              RenderTableCellText('${statsMap[company]!.contractCount}건'),
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
