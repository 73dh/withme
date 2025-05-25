import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/core/ui/color/color_style.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

class NoContactFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const NoContactFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final noContactMonth = viewModel.state.noContactMonth;
    final isActive =
        viewModel.state.currentSearchOption == SearchOption.noRecentHistory;

    final menuItems =
        NoContactMonth.values
            .map(
              (menu) => PopupMenuItem<NoContactMonth>(
                value: menu,
                child: Text(menu.toString()),
              ),
            )
            .toList();

    return RenderFilledButton(
      text: '$noContactMonth 미관리',
      menuItems: menuItems,
      onMenuSelected: (selected) {
        viewModel.onEvent(
          SearchPageEvent.filterNoRecentHistoryCustomers(month: selected as NoContactMonth),
        );
      },
      onPressed: () {
        viewModel.onEvent(
          SearchPageEvent.filterNoRecentHistoryCustomers(month: noContactMonth),
        );
      },
      backgroundColor:
          isActive
              ? ColorStyles.activeSearchButtonColor
              : ColorStyles.unActiveSearchButtonColor,
      borderRadius: 10,
    );
  }
}
