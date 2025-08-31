import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_pop_up_menu.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/domain/enum/insurance_company.dart';
import '../../../../core/domain/enum/payment_status.dart';
import '../../../../core/domain/enum/product_category.dart';
import '../search_page_event.dart';

class PolicyFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const PolicyFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: RenderPopUpMenu(
                label: viewModel.state.selectedContractMonth,
                items: ['전계약월', ...viewModel.state.contractMonths],
                icon: Icons.calendar_today,
                onSelect:
                    (month) => viewModel.onEvent(
                      SelectContractMonth(selectedContractMonth: month),
                    ),
                textColor: colorScheme.onSurface,
                iconColor: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: RenderPopUpMenu(
                label: shortenedNameText(
                  viewModel.state.productCategory.toString(),
                  length: 6,
                ),
                items: [
                  '전상품',
                  ...viewModel.state.productCategories.map((e) => e.toString()),
                ],
                icon: Icons.folder_copy_outlined,
                onSelect: (value) {
                  final selected = ProductCategory.values.firstWhere(
                    (e) => e.toString() == value,
                    orElse: () => ProductCategory.all,
                  );
                  viewModel.onEvent(
                    SelectProductCategory(productCategory: selected),
                  );
                },
                textColor: colorScheme.onSurface,
                iconColor: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: RenderPopUpMenu(
                label: shortenedNameText(
                  viewModel.state.insuranceCompany.toString(),
                  length: 6,
                ),
                items: [
                  '전보험사',
                  ...viewModel.state.insuranceCompanies.map(
                    (e) => e.toString(),
                  ),
                ],
                icon: Icons.holiday_village_outlined,
                onSelect: (value) {
                  final selected = InsuranceCompany.values.firstWhere(
                    (e) => e.toString() == value,
                    orElse: () => InsuranceCompany.all,
                  );
                  viewModel.onEvent(
                    SelectInsuranceCompany(insuranceCompany: selected),
                  );
                },
                textColor: colorScheme.onSurface,
                iconColor: colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: RenderPopUpMenu(
                label: viewModel.state.paymentStatus.label,
                // label로 표시
                items: [
                  '납입전체',
                  ...PaymentStatus.values
                      .where((e) => e != PaymentStatus.all)
                      .map((e) => e.label),
                ],
                icon: Icons.payments_outlined,
                onSelect: (value) {
                  final selected = PaymentStatus.values.firstWhere(
                    (e) => e.label == value,
                    orElse: () => PaymentStatus.all,
                  );
                  viewModel.onEvent(
                    SelectPaymentStatus(paymentStatus: selected),
                  );
                },
                textColor: colorScheme.onSurface,
                iconColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}
