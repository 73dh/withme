import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

class FetchHistoriesUseCase extends BaseStreamUseCase<CustomerRepository>{
  final String customerKey;

  FetchHistoriesUseCase({required this.customerKey});
  @override
  Stream call(CustomerRepository repository) {
   return repository.fetchHistories(customerKey: customerKey);
  }


}