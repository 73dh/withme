import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

class CustomerListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SearchPageViewModel viewModel;

  const CustomerListAppBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    final currentOption = state.currentSearchOption;

    final optionText = switch (currentOption) {
      SearchOption.noRecentHistory => state.noContactMonth,
      SearchOption.comingBirth => state.comingBirth,
      SearchOption.upcomingInsuranceAge => state.upcomingInsuranceAge,
      _ => '',
    };

    final count = state.filteredCustomers.length;
    final titleText = optionText != '' ? '$optionText $count명' : '';

    return AppBar(
      title: Text(titleText),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
