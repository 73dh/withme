import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

class GetCustomerHistoriesUseCase extends BaseUseCase<HistoryRepository>{
  final String customerKey;

  GetCustomerHistoriesUseCase({required this.customerKey});
  @override
  Future call(HistoryRepository repository) async{
   return repository.getCustomerHistories(customerKey: customerKey);
  }

}