import 'package:flutter/material.dart';

class RenderTable extends StatelessWidget {
  final Map<int, TableColumnWidth> columnWidths;
  final List<TableRow> tableRows;

  const RenderTable({
    super.key,
    required this.columnWidths,
    required this.tableRows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          columnWidths: columnWidths,
          children: tableRows,
        ),
      ),
    );
  }
}
