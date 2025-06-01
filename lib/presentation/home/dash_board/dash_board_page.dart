import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/components/custom_bar_chart.dart';
import 'package:withme/presentation/home/dash_board/components/custom_monthly_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_cell_text.dart';
import 'package:withme/presentation/home/dash_board/components/render_table_row.dart';
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
      appBar: AppBar(title: const Text('Performance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final customers = viewModel.state.customers;
            final prospect =
                customers.where((e) => e.policies.isEmpty).toList();
            final contract =
                customers.where((e) => e.policies.isNotEmpty).toList();
            final total = [...prospect, ...contract];

            final Map<String, List<CustomerModel>> flattenedMonthly = {};

            viewModel.state.monthlyCustomers?.forEach((month, typeMap) {
              final unique = <String, CustomerModel>{}; // customer.id 기준 중복 제거
              for (final customers in typeMap.values) {
                for (final c in customers) {
                  unique[c.customerKey] = c;
                }
              }
              flattenedMonthly[month] = unique.values.toList();
            });

            return LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth;
                final cellWidth = tableWidth / 5;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryTable(cellWidth, total, prospect, contract),
                      const SizedBox(height: 20),
                      const PartTitle(text: 'Monthly'),
                      const SizedBox(height: 5),
                    CustomMonthlyTable(monthlyData:  flattenedMonthly),
                      const SizedBox(height: 24),
                      CustomBarChart(monthlyData: flattenedMonthly),
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

  Widget _buildSummaryTable(
    double cellWidth,
    List<CustomerModel> total,
    List<CustomerModel> prospect,
    List<CustomerModel> contract,
  ) {
    return RenderTable(
      columnWidths: {
        for (int i = 0; i < 5; i++) i: FixedColumnWidth(cellWidth),
      },
      tableRows: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blue.shade50),
          children: const [
            RenderTableCellText('구분', isHeader: true),
            RenderTableCellText('전체 (Total)', isHeader: true),
            RenderTableCellText('가망 고객 (Prospect)', isHeader: true),
            RenderTableCellText('계약자 (Customer)', isHeader: true),
            RenderTableCellText('총 계약건수', isHeader: true),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const RenderTableCellText('고객/건'),
            RenderTableCellText('${total.length}명'),
            RenderTableCellText('${prospect.length}명'),
            RenderTableCellText('${contract.length}명'),
            RenderTableCellText(
              '${total.map((c) => c.policies.length).fold(0, (a, b) => a + b)}건',
            ),
          ],
        ),
      ],
    );
  }


}
