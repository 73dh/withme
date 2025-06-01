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
          final customers = monthlyData[key] ?? []; // null일 경우 빈 리스트로 대체
          final count = customers.fold(0, (sum, c) => sum + c.policies.length);
          return '$count';
        }).toList();

    final rows = <TableRow>[
      renderTableRow(cells: ['구분', ...sortedKeys], isHeader: true),
      renderTableRow(cells: ['가망고객', ...prospectData]),
      renderTableRow(cells: ['총 계약건수', ...contractData]),
    ];
    return RenderScrollableTable(rows: rows, sortedKeys: sortedKeys);
  }
}
