import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/data/repository/todo_repository_impl.dart';
import 'package:withme/domain/repository/todo_repository.dart';
import 'package:withme/domain/use_case/todo_use_case.dart';
import 'package:withme/presentation/customer/customer_view_model.dart';
import 'package:withme/presentation/home/dash_board/dash_board_view_model.dart';
import 'package:withme/presentation/home/search/search_page_view_model.dart';

import '../../presentation/registration/registration_view_model.dart';
import '../presentation/todo/todo_view_model.dart';
import '../router/router.dart';
import 'di_setup_import.dart';

final getIt = GetIt.instance;

Future<void> diSetup() async {
  getIt.registerLazySingleton<RouteObserver<PageRoute>>(
    () => RouteObserver<PageRoute>(),
  );

  // data
  getIt.registerSingleton<FBase>(FBase());
  getIt.registerSingleton<UserSession>(UserSession());

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
  getIt.registerSingleton<TodoRepository>(TodoRepositoryImpl(fBase: getIt()));

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
  getIt.registerSingleton<TodoUseCase>(TodoUseCase(todoRepository: getIt()));
  // viewModel
  getIt.registerLazySingleton<ProspectListViewModel>(
    () => ProspectListViewModel(),
  );
  getIt.registerLazySingleton<CustomerListViewModel>(
    () => CustomerListViewModel(),
  );
  getIt.registerSingleton<AuthChangeNotifier>(AuthChangeNotifier());

  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel());
  getIt.registerFactory<PolicyViewModel>(() => PolicyViewModel());
  getIt.registerFactory<CustomerViewModel>(() => CustomerViewModel());
  getIt.registerSingleton<SearchPageViewModel>(SearchPageViewModel());
  getIt.registerSingleton<DashBoardViewModel>(DashBoardViewModel());
  getIt.registerFactoryParam<TodoViewModel, Map<String, String>?, void>((
    params,
    _,
  ) {
    final userKey = params?['userKey'];
    final customerKey = params?['customerKey'];
    if (userKey == null || customerKey == null) {
      throw ArgumentError('userKey와 customerKey는 필수입니다.');
    }
    return TodoViewModel(userKey: userKey, customerKey: customerKey);
  });
}
