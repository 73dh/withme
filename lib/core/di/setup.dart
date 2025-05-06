import 'package:get_it/get_it.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/data/repository/customer_repository_impl.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/get_pool_use_case.dart';
import 'package:withme/presentation/home/pool/pool_view_model.dart';

final getIt = GetIt.instance;

void diSetup() {
  // data
  getIt.registerSingleton<FBase>(FBase());
  // repository
  getIt.registerSingleton<CustomerRepository>(
    CustomerRepositoryImpl(fBase: getIt()),
  );

  // use_case
  getIt.registerSingleton<GetPoolUseCase>(GetPoolUseCase());

  // viewModel
  getIt.registerFactory<PoolViewModel>(()=>PoolViewModel());
}
