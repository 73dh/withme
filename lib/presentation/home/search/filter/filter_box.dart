import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/presentation/home/search/components/policy_filter_button.dart';
import 'package:withme/presentation/home/search/filter/search_by_name_filter_button.dart';
import 'package:withme/presentation/home/search/filter/upcoming_insurance_age_filter_button.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

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
        const SizedBox(height: 17),
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
              const SizedBox(width: 5),
              Expanded(child: ComingBirthFilterButton(viewModel: viewModel)),
              const SizedBox(width: 5),
              Expanded(
                child: UpcomingInsuranceAgeFilterButton(viewModel: viewModel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
      ],
    );
  }
}
