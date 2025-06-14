import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_scrollable_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_row.dart';

import '../../../../domain/domain_import.dart';

class CustomMonthlyTable extends StatelessWidget {
  final Map<String, List<CustomerModel>> monthlyData;

  const CustomMonthlyTable({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = monthlyData.keys.toList()..sort();

    final prospectData =
        sortedKeys.map((key) {
          final customers = monthlyData[key] ?? [];
          final count = customers.where((c) => c.policies.isEmpty).length;
          return '$count';
        }).toList();

    final contractData =
        sortedKeys.map((key) {
          final customers = monthlyData[key] ?? [];
          final count = customers.fold(0, (sum, c) => sum + c.policies.length);
          return '$count';
        }).toList();

    final rows = <TableRow>[
      renderTableRow(
        cells: ['구분', ...sortedKeys],
        isHeader: true,
        backgroundColor: Colors.blue.shade50, // ✅ Header 색상 적용
      ),
      renderTableRow(
        cells: ['가망고객', ...prospectData],
        backgroundColor: Colors.grey.shade100,
        isBarProspect: true,
        isHeader: true, // ✅ Data row 색상 적용
      ),
      renderTableRow(
        cells: ['총 계약건수', ...contractData],
        backgroundColor: Colors.grey.shade100,
        isBarContract: true,
        isHeader: true, // ✅ Data row 색상 적용
      ),
    ];

    return RenderScrollableTable(rows: rows, sortedKeys: sortedKeys);
  }
}
