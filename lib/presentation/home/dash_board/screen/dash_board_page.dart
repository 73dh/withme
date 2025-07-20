import 'package:flutter/material.dart';

import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';
import 'package:withme/presentation/home/dash_board/model/customer_data_model.dart';
import 'package:withme/presentation/home/dash_board/part/custom_bar_chart.dart';
import 'package:withme/presentation/home/dash_board/part/custom_monthly_table.dart';
import 'package:withme/presentation/home/dash_board/part/custom_summery_table.dart';
import 'package:withme/presentation/home/dash_board/part/insurance_company_summery_table.dart';
import 'package:withme/presentation/home/dash_board/part/product_category_summery_table.dart';

import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../core/ui/core_ui_import.dart';

class DashBoardPage extends StatelessWidget {
  final DashBoardViewModel viewModel;
  final void Function() onMenuTap;
  final AnimationController animationController;

  const DashBoardPage({
    super.key,
    required this.viewModel,
    required this.onMenuTap,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final processedData = processCustomerData(
      viewModel.state.customers,
      viewModel.state.monthlyCustomers,
    );
    final customers = viewModel.state.customers;

    return AnimatedPositioned(
      duration: AppDurations.duration300,
      left: viewModel.state.bodyXPosition,
      right: -viewModel.state.bodyXPosition,
      top: 0,
      bottom: 0,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('DashBoard'),
          actions: [
            IconButton(onPressed: onMenuTap, icon: const Icon(Icons.settings)),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth;
                final cellWidth = tableWidth / 5;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const PartTitle(text: '고객수 종합'),
                    CustomSummeryTable(
                      cellWidth: cellWidth,
                      total: processedData.total,
                      prospect: processedData.prospect,
                      contract: processedData.contract,
                    ),
                    height(5),
                    const PartTitle(text: '보험사'),
                    InsuranceCompanySummaryTable(
                      cellWidth: cellWidth,
                      customers: customers,
                    ),
                    height(5),
                    const PartTitle(text: '판매상품'),
                    ProductCategorySummaryTable(
                      cellWidth: cellWidth,
                      customers: customers,
                    ),
                    height(5),
                    const PartTitle(text: '월별 고객 및 건수'),
                    CustomMonthlyTable(
                      monthlyData: processedData.flattenedMonthly,
                    ),

                    height(20),
                    const PartTitle(text: 'Monthly Chart'),
                    height(10),
                    CustomBarChart(monthlyData: processedData.flattenedMonthly),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
