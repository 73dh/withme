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

    final rows = <TableRow>[
      renderTableRow(
        cells: ['구분', ...sortedKeys],
        isHeader: true,
        textStyle: textStyle ?? theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        backgroundColor: colorScheme.surfaceVariant, // M3 surfaceVariant 적용
      ),
      renderTableRow(
        cells: ['가망고객', ...prospectData],
        textStyle: textStyle ?? theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        backgroundColor: colorScheme.surface, // M3 surface 적용
        isBarProspect: true,
      ),
      renderTableRow(
        cells: ['총 계약건수', ...contractData],
        textStyle: textStyle ?? theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        backgroundColor: colorScheme.surface, // M3 surface 적용
        isBarContract: true,
      ),
    ];

    return RenderScrollableTable(rows: rows, sortedKeys: sortedKeys);
  }
}
