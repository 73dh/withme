import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/render_filled_button.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

class NoContactFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const NoContactFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final noContactMonth = viewModel.state.noContactMonth;
    final isActive =
        viewModel.state.currentSearchOption == SearchOption.noRecentHistory;

    final menuItems =
        NoContactMonth.values
            .map(
              (menu) => PopupMenuItem<NoContactMonth>(
                value: menu,
                child: Text(
                  menu.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            )
            .toList();

    return RenderFilledButton(
      text: '$noContactMonth',
      menuItems: menuItems,
      onMenuSelected: (selected) {
        viewModel.onEvent(
          SearchPageEvent.filterNoRecentHistoryCustomers(
            month: selected as NoContactMonth,
          ),
        );
      },
      onPressed: () {
        viewModel.onEvent(
          SearchPageEvent.filterNoRecentHistoryCustomers(month: noContactMonth),
        );
      },
      backgroundColor:
          isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
      // Theme 기반 색상
      foregroundColor:
          isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
      // 텍스트 색상 자동
      borderRadius: 10,
    );
  }
}
