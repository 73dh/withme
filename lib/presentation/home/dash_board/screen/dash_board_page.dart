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
  final VoidCallback onMenuTap;
  final AnimationController animationController;

  const DashBoardPage({
    super.key,
    required this.viewModel,
    required this.onMenuTap,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final processedData = processCustomerData(
      viewModel.state.customers,
      viewModel.state.monthlyCustomers,
    );
    final customers = viewModel.state.customers;

    Widget height(double h) => SizedBox(height: h);

    return Stack(
      children: [
        AnimatedPositioned(
          duration: AppDurations.duration300,
          left: viewModel.state.bodyXPosition,
          right: -viewModel.state.bodyXPosition,
          top: 0,
          bottom: 0,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: Text(
                'DashBoard',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: colorScheme.surface,
              elevation: 0,
              iconTheme: IconThemeData(color: colorScheme.onSurface),
              actions: [
                IconButton(
                  onPressed: onMenuTap,
                  icon: Icon(Icons.settings, color: colorScheme.primary),
                ),
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
                        PartTitle(text: '고객수 종합', color: colorScheme.onSurface),
                        CustomSummeryTable(
                          cellWidth: cellWidth,
                          total: processedData.total,
                          prospect: processedData.prospect,
                          contract: processedData.contract,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          cellColor: colorScheme.surfaceContainerHighest,
                        ),
                        height(5),
                        PartTitle(text: '보험사', color: colorScheme.onSurface),
                        InsuranceCompanySummaryTable(
                          cellWidth: cellWidth,
                          customers: customers,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          cellColor: colorScheme.surfaceContainerHighest,
                        ),
                        height(5),
                        PartTitle(text: '판매상품', color: colorScheme.onSurface),
                        ProductCategorySummaryTable(
                          cellWidth: cellWidth,
                          customers: customers,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          cellColor: colorScheme.surfaceContainerHighest,
                        ),
                        height(5),
                        PartTitle(
                          text: '월별 고객 및 건수',
                          color: colorScheme.onSurface,
                        ),
                        CustomMonthlyTable(
                          monthlyData: processedData.flattenedMonthly,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        height(20),
                        PartTitle(
                          text: 'Monthly Chart',
                          color: colorScheme.onSurface,
                        ),
                        height(10),
                        CustomBarChart(
                          monthlyData: processedData.flattenedMonthly,
                          prospectBarColor: colorScheme.primary,
                          contractBarColor: colorScheme.secondary,
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
