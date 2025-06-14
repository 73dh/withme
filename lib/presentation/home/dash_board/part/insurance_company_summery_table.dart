import 'package:flutter/material.dart';
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
            RenderTableCellText('보험사', isHeader: true),
            RenderTableCellText('고객 수', isHeader: true),
            RenderTableCellText('계약 건수', isHeader: true),
          ],
        ),
        for (final company in sortedKeys)
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              RenderTableCellText(company),
              RenderTableCellText('${statsMap[company]!.customerCount}명'),
              RenderTableCellText('${statsMap[company]!.contractCount}건'),
            ],
          ),
      ],
    );
  }
}

class _InsuranceCompanyStats {
  int customerCount = 0;
  int contractCount = 0;
}
