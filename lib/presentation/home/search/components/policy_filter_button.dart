import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_pop_up_menu.dart';
import 'package:withme/core/utils/core_utils_import.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/domain/enum/insurance_company.dart';
import '../../../../core/domain/enum/product_category.dart';
import '../../../../core/ui/color/color_style.dart';
import '../search_page_event.dart';

class PolicyFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const PolicyFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isActive =
        viewModel.state.currentSearchOption == SearchOption.filterPolicy &&
        !viewModel.state.isSearchingByName;

    return LayoutBuilder(
      builder: (context, constraint) {
        final double totalWidth = constraint.maxWidth;
        final double firstItemWidth = totalWidth * 0.8;
        return Row(
          children: [
            SizedBox(
              width: firstItemWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RenderPopUpMenu(
                    label: viewModel.state.selectedContractMonth,
                    items: ['전계약월', ...viewModel.state.contractMonths],
                    icon: Icons.calendar_today,
                    onSelect:
                        (month) => viewModel.onEvent(
                          SelectContractMonth(selectedContractMonth: month),
                        ),
                  ),
                  RenderPopUpMenu(
                    label: shortenedNameText(
                      viewModel.state.productCategory.toString(),
                      length: 6,
                    ),
                    // items: ProductCategory.values,
                    items: [
                      '전상품',
                      ...viewModel.state.productCategories.map(
                        (e) => e.toString(),
                      ),
                    ],
                    icon: Icons.folder_copy_outlined,
                    onSelect: (value) {
                      final selected = ProductCategory.values.firstWhere(
                        (e) => e.toString() == value,
                        orElse: () => ProductCategory.all, // 필요시 추가 정의
                      );
                      viewModel.onEvent(
                        SelectProductCategory(productCategory: selected),
                      );
                    },
                  ),

                  RenderPopUpMenu(
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
                        orElse: () => InsuranceCompany.all, // 필요시 추가 정의
                      );
                      viewModel.onEvent(
                        SelectInsuranceCompany(insuranceCompany: selected),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(
              width: totalWidth - firstItemWidth,
              child: GestureDetector(
                onTap: () {
                  viewModel.onEvent(
                    SearchPageEvent.filterPolicy(
                      productCategory: viewModel.state.productCategory,
                      insuranceCompany: viewModel.state.insuranceCompany,
                      selectedContractMonth:
                          viewModel.state.selectedContractMonth,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? ColorStyles.activeSearchButtonColor
                              : ColorStyles.unActiveSearchButtonColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.search,
                      color: Colors.black87, // 아이콘 색상
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
