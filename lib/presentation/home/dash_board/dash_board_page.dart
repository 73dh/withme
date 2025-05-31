import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/render_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';

import '../../../core/di/setup.dart';
import '../../../core/presentation/core_presentation_import.dart';
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
                final cellWidth = tableWidth / 5;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      RenderTable(
                        columnWidths: {
                          0: FixedColumnWidth(cellWidth),
                          1: FixedColumnWidth(cellWidth),
                          2: FixedColumnWidth(cellWidth),
                          3: FixedColumnWidth(cellWidth),
                          4: FixedColumnWidth(cellWidth),
                        },
                        tableRows: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                            ),
                            children: const [
                              RenderTableCellText('구분', isHeader: true),
                              RenderTableCellText('전체 (Total)', isHeader: true),
                              RenderTableCellText(
                                '가망 고객 (Prospect)',
                                isHeader: true,
                              ),
                              RenderTableCellText(
                                '계약자 (Customer)',
                                isHeader: true,
                              ),
                              RenderTableCellText('총 계약건수', isHeader: true),
                              // 새 헤더
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                            children: [
                              RenderTableCellText('인원 수'),
                              RenderTableCellText('${total.length}명'),
                              RenderTableCellText('${prospect.length}명'),
                              RenderTableCellText('${customer.length}명'),
                              RenderTableCellText(
                                '${total.map((c) => c.policies?.length ?? 0).fold(0, (a, b) => a + b)}건',
                              ), // 총 계약건수
                            ],
                          ),
                        ],
                      ),

                      height(20),
                      PartTitle(text: '월별 고객 현황'),

                      height(5),
                      _buildMonthlyTable(viewModel.state.monthlyCustomers),

                      const SizedBox(height: 24),
                      _buildBarChart(
                        convertToStats(viewModel.state.monthlyCustomers),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Widget _buildMonthlyTable(Map<String, List<CustomerModel>> monthlyData) {
  final sortedKeys = monthlyData.keys.toList()..sort();

  return RenderTable(
    columnWidths: const {
      0: FlexColumnWidth(2), // 월
      1: FlexColumnWidth(1.5), // 가망고객
      2: FlexColumnWidth(1.5), // 고객
      3: FlexColumnWidth(1.5), // 총 계약 건수
    },
    tableRows: [
      // 헤더
      TableRow(
        decoration: BoxDecoration(color: Colors.blue.shade50),
        children: const [
          RenderTableCellText('월', isHeader: true),
          RenderTableCellText('가망고객', isHeader: true),
          RenderTableCellText('고객', isHeader: true),
          RenderTableCellText('총 계약건수', isHeader: true),
        ],
      ),

      // 각 월 데이터 행
      for (var monthKey in sortedKeys)
        TableRow(
          children: [
            RenderTableCellText(monthKey),
            RenderTableCellText(
              '${monthlyData[monthKey]!.where((c) => (c.policies ?? []).isEmpty).length}',
            ),
            RenderTableCellText(
              '${monthlyData[monthKey]!.where((c) => (c.policies ?? []).isNotEmpty).length}',
            ),
            RenderTableCellText(
              '${monthlyData[monthKey]!.map((c) => c.policies?.length ?? 0).fold(0, (a, b) => a + b)}',
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

Widget _buildBarChart(Map<String, Map<String, int>> stats) {
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
