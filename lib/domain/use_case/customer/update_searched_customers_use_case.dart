import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../presentation/home/search/enum/search_option.dart';
import '../../../presentation/home/search/search_page_event.dart';

class UpdateSearchedCustomersUseCase {
  static Future<void> call(SearchPageViewModel viewModel) async {
    final state = viewModel.state;
    final currentOption = state.currentSearchOption;
    await viewModel.getAllData();
    final event = switch (currentOption) {
      SearchOption.noRecentHistory =>
        SearchPageEvent.filterNoRecentHistoryCustomers(
          month: state.noContactMonth,
        ),
      SearchOption.comingBirth => SearchPageEvent.filterComingBirth(
        birthDay: state.comingBirth,
      ),
      SearchOption.upcomingInsuranceAge =>
        SearchPageEvent.filterUpcomingInsuranceAge(
          insuranceAge: state.upcomingInsuranceAge,
        ),
      SearchOption.noBirth => SearchPageEvent.filterNoBirthCustomers(),
      _ => null,
    };

    if (event != null) {
      await viewModel.onEvent(event);
    }
  }
}
