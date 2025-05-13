import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

class GetHistoriesUseCase extends BaseStreamUseCase<CustomerRepository>{
  final String customerKey;

  GetHistoriesUseCase({required this.customerKey});
  @override
  Stream call(CustomerRepository repository) {
   return repository.getHistories(customerKey: customerKey);
  }


}