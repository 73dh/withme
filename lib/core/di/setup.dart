import 'package:withme/presentation/customer/customer_view_model.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import 'di_setup_import.dart';

final getIt = GetIt.instance;

Future<void> diSetup() async {
  // data
  getIt.registerSingleton<FBase>(FBase());

  // repository
  getIt.registerSingleton<CustomerRepository>(
    CustomerRepositoryImpl(fBase: getIt()),
  );
  getIt.registerSingleton<HistoryRepository>(
    HistoryRepositoryImpl(fBase: getIt()),
  );
  getIt.registerSingleton<PolicyRepository>(
    PolicyRepositoryImpl(fBase: getIt()),
  );

  // use_case
  getIt.registerSingleton<CustomerUseCase>(
    CustomerUseCase(customerRepository: getIt()),
  );
  getIt.registerSingleton<HistoryUseCase>(
    HistoryUseCase(historyRepository: getIt()),
  );
  getIt.registerSingleton<PolicyUseCase>(
    PolicyUseCase(policyRepository: getIt()),
  );

  // viewModel
  getIt.registerFactory<ProspectListViewModel>(() => ProspectListViewModel());
  getIt.registerFactory<CustomerListViewModel>(() => CustomerListViewModel());
  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel());
  getIt.registerFactory<PolicyViewModel>(() => PolicyViewModel());
  getIt.registerFactory<CustomerViewModel>(() => CustomerViewModel());
  getIt.registerFactory<SearchPageViewModel>(() => SearchPageViewModel());
 getIt.registerSingleton<DashBoardViewModel>( DashBoardViewModel());

}
