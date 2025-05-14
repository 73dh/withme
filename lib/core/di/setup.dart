import 'package:get_it/get_it.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/data/repository/history_repository_impl.dart';
import 'package:withme/data/repository/policy_repository_impl.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/repository/history_repository.dart';
import 'package:withme/domain/repository/policy_repository.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/history_use_case.dart';
import 'package:withme/presentation/home/customer/customer_view_model.dart';
import 'package:withme/presentation/home/prospect/prospect_view_model.dart';
import 'package:withme/presentation/policy/policy_view_model.dart';
import 'package:withme/presentation/registration/registration_view_model.dart';

import '../../domain/use_case/policy_use_case.dart';

final getIt = GetIt.instance;

void diSetup() {
  // data
  getIt.registerSingleton<FBase>(FBase());

  // repository
  getIt.registerSingleton<CustomerRepository>(
    CustomerRepositoryImpl(fBase: getIt()),
  );
  getIt.registerSingleton<HistoryRepository>(HistoryRepositoryImpl(fBase: getIt()));
  getIt.registerSingleton<PolicyRepository>(PolicyRepositoryImpl(fBase: getIt()));

  // use_case
  getIt.registerSingleton<CustomerUseCase>(
    CustomerUseCase(customerRepository: getIt()),
  );
  getIt.registerSingleton<HistoryUseCase>(HistoryUseCase(historyRepository: getIt()));
  getIt.registerSingleton<PolicyUseCase>(PolicyUseCase(policyRepository: getIt()));
  // getIt.registerSingleton<GetAllUseCase>(GetAllUseCase());

  // viewModel
  getIt.registerFactory<ProspectViewModel>(() => ProspectViewModel());
  getIt.registerFactory<CustomerViewModel>(() => CustomerViewModel());
  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel());
  getIt.registerFactory<PolicyViewModel>(() => PolicyViewModel());
}
