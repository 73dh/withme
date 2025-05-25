import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../../core/presentation/components/render_filled_button.dart';
import '../../../../core/ui/color/color_style.dart';
import '../search_page_event.dart';

class ComingBirthFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;

  const ComingBirthFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final comingBirth = viewModel.state.comingBirth;
    final isActive =
        viewModel.state.currentSearchOption == SearchOption.comingBirth;

    final menuItems =
    ComingBirth.values
        .map(
          (menu) =>
          PopupMenuItem<ComingBirth>(
            value: menu,
            child: Text(menu.toString()),
          ),
    )
        .toList();

    return RenderFilledButton(
      text: '$comingBirth',
      menuItems: menuItems,
      onMenuSelected: (selected) {
        viewModel.onEvent(
          SearchPageEvent.filterComingBirth(birthDay: selected as ComingBirth),
        );
      },
      onPressed: () {
        viewModel.onEvent(
          SearchPageEvent.filterComingBirth(birthDay: comingBirth),
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
