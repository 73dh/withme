import 'package:flutter/material.dart';
import 'package:withme/presentation/home/search/enum/search_option.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';

import '../../../../core/presentation/components/render_filled_button.dart';
import '../../../../core/ui/color/color_style.dart';
import '../search_page_view_model.dart';

class NoBirthFilterButton extends StatelessWidget {
  final SearchPageViewModel viewModel;
  const NoBirthFilterButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isActive = viewModel.state.currentSearchOption == SearchOption.noBirth;
    return RenderFilledButton(
      onPressed: () {
        viewModel.onEvent(SearchPageEvent.filterNoBirthCustomers());
      },
      text: '생년월일 정보 없음',
      backgroundColor:
      isActive
          ? ColorStyles.activeSearchButtonColor
          : ColorStyles.unActiveSearchButtonColor,
      borderRadius: 10,
    );
  }
}
