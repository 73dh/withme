import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../domain_import.dart';
import 'base/base_use_case.dart';

 class CustomerUseCase  {
  final CustomerRepository _customerRepository;

  CustomerUseCase({required CustomerRepository customerRepository})
    : _customerRepository = customerRepository;

  Future execute<T>({required BaseUseCase usecase}) async {
    return  usecase(_customerRepository);
  }

  Stream<R> call<R>({required BaseStreamUseCase<R,CustomerRepository> usecase}){
    return usecase(_customerRepository) ;
  }
}
