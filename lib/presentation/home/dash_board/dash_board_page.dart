import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/dash_board/part/custom_bar_chart.dart';
import 'package:withme/presentation/home/dash_board/part/custom_monthly_table.dart';
import 'package:withme/presentation/home/dash_board/part/custom_summery_table.dart';
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
                      const PartTitle(text: 'Summery'),
                      CustomSummeryTable(
                        cellWidth: cellWidth,
                        total: total,
                        prospect: prospect,
                        contract: contract,
                      ),
                      height(20),
                      const PartTitle(text: 'Monthly'),
                      height(5),
                      CustomMonthlyTable(monthlyData: flattenedMonthly),
                      height(24),
                      const PartTitle(text: 'Monthly Chart'),
                    height(10),
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
}
