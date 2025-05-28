import 'dart:math';

import 'package:flutter/material.dart';

class TableFormat extends StatelessWidget {
  final Map<int, TableColumnWidth>? columnWidths;
  final List<TableRow> tableRows;

  const TableFormat({super.key, this.columnWidths, required this.tableRows});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        columnWidths: columnWidths,
        children: tableRows,
      ),
    );
  }
}
