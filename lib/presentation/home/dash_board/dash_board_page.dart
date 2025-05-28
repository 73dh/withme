import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../domain/model/customer_model.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<DashBoardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('대시보드')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final prospect =
                viewModel.state.customers
                    .where((e) => e.policies.isEmpty)
                    .toList();
            final customer =
                viewModel.state.customers
                    .where((e) => e.policies.isNotEmpty)
                    .toList();
            final total = [...prospect, ...customer];
            return LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth;
                final cellWidth = tableWidth / 4;
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          columnWidths: {
                            0: FixedColumnWidth(cellWidth),
                            1: FixedColumnWidth(cellWidth),
                            2: FixedColumnWidth(cellWidth),
                            3: FixedColumnWidth(cellWidth),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                              ),
                              children: const [
                                _TableCellText('구분', isHeader: true),
                                _TableCellText('전체 (Total)', isHeader: true),
                                _TableCellText(
                                  '가망 고객 (Prospect)',
                                  isHeader: true,
                                ),
                                _TableCellText(
                                  '계약자 (Customer)',
                                  isHeader: true,
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                              ),
                              children: [
                                _TableCellText('인원 수'),
                                _TableCellText('${total.length}명'),
                                _TableCellText('${prospect.length}명'),
                                _TableCellText('${customer.length}명'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          '월별 고객 현황',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        buildMonthlyTable(viewModel.state.monthlyCustomers),

                        const SizedBox(height: 24),
                        buildBarChart(
                          convertToStats(viewModel.state.monthlyCustomers),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TableCellText extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCellText(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      alignment: Alignment.center,
      color: isHeader ? Colors.transparent : null,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}

Widget buildMonthlyTable(Map<String, List<CustomerModel>> monthlyData) {
  final sortedKeys = monthlyData .keys.toList()..sort();

  return Table(
    border: TableBorder.all(),
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(1.5),
      2: FlexColumnWidth(1.5),
    },
    children: [
      // 헤더
      const TableRow(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('월', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '가망고객 수',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('계약자 수', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      // 각 월에 대한 데이터 행
      for (var monthKey in sortedKeys)
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(8.0), child: Text(monthKey)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${monthlyData[monthKey]!.where((c) => (c.policies ?? []).isEmpty).length}',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${monthlyData[monthKey]!.where((c) => (c.policies ?? []).isNotEmpty).length}',
              ),
            ),
          ],
        ),
    ],
  );
}

BarChartGroupData generateBarGroup(
  String month,
  int index,
  int prospect,
  int customer,
) {
  return BarChartGroupData(
    x: index,
    barRods: [
      BarChartRodData(toY: prospect.toDouble(), color: Colors.orange, width: 8),
      BarChartRodData(toY: customer.toDouble(), color: Colors.blue, width: 8),
    ],
  );
}

Widget buildBarChart(Map<String, Map<String, int>> stats) {
  final keys = stats.keys.toList()..sort();

  return SizedBox(
    height: 300,
    child: BarChart(
      BarChartData(
        barGroups: List.generate(keys.length, (i) {
          final key = keys[i];
          final data = stats[key]!;
          return generateBarGroup(key, i, data['prospect']!, data['customer']!);
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                return Text(keys[idx].substring(5)); // "2025-05" → "05"
              },
            ),
          ),
        ),
      ),
    ),
  );
}

Map<String, Map<String, int>> convertToStats(
  Map<String, List<CustomerModel>> monthlyData,
) {
  final Map<String, Map<String, int>> stats = {};

  for (final entry in monthlyData.entries) {
    final monthKey = entry.key;
    final customers = entry.value;

    final prospectCount =
        customers.where((c) => (c.policies ?? []).isEmpty).length;
    final customerCount =
        customers.where((c) => (c.policies ?? []).isNotEmpty).length;

    stats[monthKey] = {'prospect': prospectCount, 'customer': customerCount};
  }

  return stats;
}
