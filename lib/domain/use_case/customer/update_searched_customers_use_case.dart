import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../../presentation/home/search/enum/search_option.dart';
import '../../../presentation/home/search/search_page_event.dart';

class UpdateSearchedCustomersUseCase {
  static Future<void> call(SearchPageViewModel viewModel) async {
    final previousOption = viewModel.state.currentSearchOption;
    final state = viewModel.state;

    // 1. 최신 데이터 로드
    await viewModel.getAllData();

    // 2. 선택된 필터 조건 재적용
    final event = switch (previousOption) {
      SearchOption.noRecentHistory => SearchPageEvent.filterNoRecentHistoryCustomers(
        month: state.noContactMonth,
      ),
      SearchOption.comingBirth => SearchPageEvent.filterComingBirth(
        birthDay: state.comingBirth,
      ),
      SearchOption.upcomingInsuranceAge => SearchPageEvent.filterUpcomingInsuranceAge(
        insuranceAge: state.upcomingInsuranceAge,
      ),
      SearchOption.filterPolicy => SearchPageEvent.filterPolicy(
        productCategory: state.productCategory,
        insuranceCompany: state.insuranceCompany,
        selectedContractMonth: state.selectedContractMonth,
      ),
      _ => null,
    };

    if (event != null) {
      await viewModel.onEvent(event);
    }
  }
}


// class UpdateSearchedCustomersUseCase {
//   static Future<void> call(SearchPageViewModel viewModel) async {
//     final state = viewModel.state;
//     final currentOption = state.currentSearchOption;
//     await viewModel.getAllData();
//     final event = switch (currentOption) {
//       SearchOption.noRecentHistory =>
//         SearchPageEvent.filterNoRecentHistoryCustomers(
//           month: state.noContactMonth,
//         ),
//       SearchOption.comingBirth => SearchPageEvent.filterComingBirth(
//         birthDay: state.comingBirth,
//       ),
//       SearchOption.upcomingInsuranceAge =>
//         SearchPageEvent.filterUpcomingInsuranceAge(
//           insuranceAge: state.upcomingInsuranceAge,
//         ),
//     // Todo: 삭제
//     //   SearchOption.noBirth => SearchPageEvent.filterNoBirthCustomers(),
//       _ => null,
//     };
//
//     if (event != null) {
//       await viewModel.onEvent(event);
//     }
//   }
// }
