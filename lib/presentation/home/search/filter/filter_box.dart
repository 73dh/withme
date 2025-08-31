import 'package:withme/core/domain/core_domain_import.dart';
import 'package:withme/core/domain/enum/payment_status.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/presentation/home/search/components/policy_filter_button.dart';
import 'package:withme/presentation/home/search/filter/search_by_name_filter_button.dart';
import 'package:withme/presentation/home/search/filter/upcoming_insurance_age_filter_button.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../search_page_event.dart';
import 'coming_birth_filter_button.dart';
import 'no_contact_filter_button.dart';

class FilterBox extends StatelessWidget {
  final SearchPageViewModel viewModel;
  final ScrollController controller;
  final bool isSearchingByName;
  final FocusNode searchFocusNode;
  final VoidCallback onToggleSearch;

  const FilterBox({
    super.key,
    required this.viewModel,
    required this.controller,
    required this.isSearchingByName,
    required this.searchFocusNode,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView(
      controller: controller,
      children: [
        _buildDragHandle(colorScheme),
        height(17),
        PartTitle(
          text: '고객조회',
          verticalPadding: 6,
          style: textTheme.titleMedium?.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        ItemContainer(
          height: 60,
          child: Row(
            children: [
              Expanded(child: NoContactFilterButton(viewModel: viewModel)),
              width(5),
              Expanded(child: ComingBirthFilterButton(viewModel: viewModel)),
              width(5),
              Expanded(
                child: UpcomingInsuranceAgeFilterButton(viewModel: viewModel),
              ),
            ],
          ),
        ),
        height(14),
        _buildSearchByName(context, colorScheme, textTheme),
        ItemContainer(
          height: 60,
          child: PolicyFilterButton(viewModel: viewModel),
        ),
      ],
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSearchByName(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // 현재 조건이 하나라도 선택되어 있으면 true
    final hasActiveFilters =
        viewModel.state.productCategory != ProductCategory.all ||
        viewModel.state.insuranceCompany != InsuranceCompany.all ||
        viewModel.state.selectedContractMonth != '전계약월' ||
        viewModel.state.paymentStatus != PaymentStatus.all;
    return Row(
      children: [
        Expanded(
          child: PartTitle(
            text: '계약조회',
            verticalPadding: 6,
            style: textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (isSearchingByName)
          SearchByNameFilterButton(
            viewModel: viewModel,
            focusNode: searchFocusNode,
          ),
        GestureDetector(
          onTap: onToggleSearch,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
            child: Icon(
              isSearchingByName ? Icons.close : Icons.person_search_outlined,
              color: colorScheme.primary,
            ),
          ),
        ),
        // ✅ 검색 버튼 추가
        GestureDetector(
          onTap: () {
            if (hasActiveFilters) {
              viewModel.resetFilters();
            } else {
              viewModel.onEvent(
                SearchPageEvent.filterPolicy(
                  productCategory: viewModel.state.productCategory,
                  insuranceCompany: viewModel.state.insuranceCompany,
                  selectedContractMonth: viewModel.state.selectedContractMonth,
                  paymentStatus: viewModel.state.paymentStatus,
                ),
              );
            }
          },
          child: Container(
            width: 60,
            margin: const EdgeInsets.only(left: 8, right: 4, bottom: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  hasActiveFilters
                      ? colorScheme.errorContainer
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasActiveFilters ? Icons.refresh : Icons.search,
              color:
                  hasActiveFilters
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
