import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/components/render_pop_up_menu.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/domain/enum/insurance_company.dart';
import '../../../../core/domain/enum/product_category.dart';
import '../../../../core/presentation/components/render_filled_button.dart';
import '../../../../core/ui/color/color_style.dart';
import '../search_page_event.dart';

class PolicyFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const PolicyFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isActive =
        viewModel.state.currentSearchOption == SearchOption.filterPolicy;

    return Row(
      children: [
        RenderPopUpMenu(
          label: viewModel.state.selectedContractMonth ?? '계약월 선택',
          items: viewModel.state.contractMonths,
          onSelect: (month) => viewModel.onEvent(
            SelectContractMonth(selectedContractMonth: month),
          ),
        ),
        RenderPopUpMenu(
          label: viewModel.state.productCategory.toString() ,
          items: ProductCategory.values,
          onSelect:
              (e ) {
                viewModel.onEvent(
                SelectProductCategory(productCategory: e),
              );
              },
        ),

        RenderPopUpMenu(
          label: viewModel.state.insuranceCompany.toString(),
          items: InsuranceCompany.values,
          onSelect:
              (e) => viewModel.onEvent(
                SelectInsuranceCompany(insuranceCompany: e),
              ),
        ),
        Expanded(
          child: RenderFilledButton(
            onPressed: () {
              viewModel.onEvent(
                SearchPageEvent.filterPolicy(
                  productCategory: viewModel.state.productCategory,
                  insuranceCompany: viewModel.state.insuranceCompany,
                  selectedContractMonth: viewModel.state.selectedContractMonth??''

                ),
              );
            },
            text: '조회',
            backgroundColor:
                isActive
                    ? ColorStyles.activeSearchButtonColor
                    : ColorStyles.unActiveSearchButtonColor,
            borderRadius: 10,
          ),
        ),
      ],
    );
  }
}
