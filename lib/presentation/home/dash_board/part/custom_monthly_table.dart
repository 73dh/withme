import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_scrollable_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_row.dart';

import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_scrollable_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_row.dart';

import '../../../../core/ui/core_ui_import.dart';
import '../../../../domain/domain_import.dart';

class CustomMonthlyTable extends StatelessWidget {
  final Map<String, List<CustomerModel>> monthlyData;
  final TextStyle? textStyle; // theme 적용용

  const CustomMonthlyTable({
    super.key,
    required this.monthlyData,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortedKeys = monthlyData.keys.toList()..sort();

    final prospectData = sortedKeys.map((key) {
      final customers = monthlyData[key] ?? [];
      final count = customers.where((c) => c.policies.isEmpty).length;
      return '$count';
    }).toList();

    final contractData = sortedKeys.map((key) {
      final customers = monthlyData[key] ?? [];
      final count = customers.fold(0, (sum, c) => sum + c.policies.length);
      return '$count';
    }).toList();

    final headerTextStyle = (textStyle ?? theme.textTheme.bodyMedium)?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    final rowTextStyle = textStyle ?? theme.textTheme.bodyMedium;

    final rows = <TableRow>[
      // 헤더 행
      renderTableRow(
        cells: ['구분', ...sortedKeys],
        isHeader: true,
        textStyle: headerTextStyle,
        backgroundColor: colorScheme.primaryContainer,
      ),
      // 가망고객 행
      renderTableRow(
        cells: ['가망고객', ...prospectData],
        textStyle: rowTextStyle,
        backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.8),
        isBarProspect: true,
      ),
      // 총 계약건수 행
      renderTableRow(
        cells: ['총 계약건수', ...contractData],
        textStyle: rowTextStyle,
        backgroundColor: colorScheme.surfaceVariant.withValues(alpha: 0.8),
        isBarContract: true,
      ),
    ];

    return RenderScrollableTable(rows: rows, sortedKeys: sortedKeys);
  }
}
