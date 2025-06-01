import 'package:flutter/material.dart';
import 'package:withme/core/utils/core_utils_import.dart';
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

    return LayoutBuilder(
      builder: (context,constraint) {
        final double totalWidth = constraint.maxWidth;
        final double firstItemWidth = totalWidth * 0.7;
        return Row(
          children: [
            SizedBox(
              width: firstItemWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RenderPopUpMenu(
                    label: viewModel.state.selectedContractMonth ,
                    items: ['전계약월',...viewModel.state.contractMonths],
                    onSelect:
                        (month) => viewModel.onEvent(
                          SelectContractMonth(selectedContractMonth: month),
                        ),
                  ),
                  RenderPopUpMenu(
                    label:shortenedNameText( viewModel.state.productCategory.toString(),length: 6),
                    items: ProductCategory.values,
                    onSelect: (e) {
                      viewModel.onEvent(SelectProductCategory(productCategory: e));
                    },
                  ),

                  RenderPopUpMenu(
                    label:shortenedNameText( viewModel.state.insuranceCompany.toString(),length: 6),
                    items: InsuranceCompany.values,
                    onSelect:
                        (e) => viewModel.onEvent(
                          SelectInsuranceCompany(insuranceCompany: e),
                        ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width:totalWidth- firstItemWidth,
              child: RenderFilledButton(
                onPressed: () {
                  viewModel.onEvent(
                    SearchPageEvent.filterPolicy(
                      productCategory: viewModel.state.productCategory,
                      insuranceCompany: viewModel.state.insuranceCompany,
                      selectedContractMonth:
                          viewModel.state.selectedContractMonth ?? '',
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
    );
  }
}
