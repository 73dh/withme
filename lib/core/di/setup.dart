import 'package:get_it/get_it.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/presentation/home/customer/customer_view_model.dart';
import 'package:withme/presentation/home/prospect/prospect_view_model.dart';
import 'package:withme/presentation/registration/registration_view_model.dart';

final getIt = GetIt.instance;

void diSetup() {
  // data
  getIt.registerSingleton<FBase>(FBase());

  // repository
  getIt.registerSingleton<CustomerRepository>(
    CustomerRepositoryImpl(fBase: getIt()),
  );

  // use_case
  getIt.registerSingleton<CustomerUseCase>(
    CustomerUseCase(customerRepository: getIt()),
  );
  getIt.registerSingleton<GetAllUseCase>(GetAllUseCase());

  // viewModel
  getIt.registerFactory<ProspectViewModel>(() => ProspectViewModel());
  getIt.registerFactory<CustomerViewModel>(() => CustomerViewModel());
  getIt.registerFactory<RegistrationViewModel>(() => RegistrationViewModel());
}
