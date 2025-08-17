import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/presentation/components/render_filled_button.dart';
import '../../../../core/ui/color/color_style.dart';
import '../enum/search_option.dart';
import '../search_page_event.dart';
import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';
import '../../../../core/presentation/components/render_filled_button.dart';
import '../enum/search_option.dart';
import '../search_page_event.dart';

class UpcomingInsuranceAgeFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const UpcomingInsuranceAgeFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final upcomingInsuranceAge = viewModel.state.upcomingInsuranceAge;
    final isActive =
        viewModel.state.currentSearchOption ==
            SearchOption.upcomingInsuranceAge;

    final menuItems = UpcomingInsuranceAge.values.map(
          (menu) => PopupMenuItem<UpcomingInsuranceAge>(
        value: menu,
        child: Text(
          menu.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ).toList();

    return RenderFilledButton(
      text: '$upcomingInsuranceAge',
      menuItems: menuItems,
      onMenuSelected: (selected) {
        viewModel.onEvent(
          SearchPageEvent.filterUpcomingInsuranceAge(
            insuranceAge: selected as UpcomingInsuranceAge,
          ),
        );
      },
      onPressed: () {
        viewModel.onEvent(
          SearchPageEvent.filterUpcomingInsuranceAge(
            insuranceAge: upcomingInsuranceAge,
          ),
        );
      },
      backgroundColor: isActive
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      foregroundColor: isActive
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurfaceVariant,
      borderRadius: 10,
    );
  }
}
