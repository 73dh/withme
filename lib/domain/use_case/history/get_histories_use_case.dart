import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/repository/history_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

class GetHistoriesUseCase extends BaseStreamUseCase<HistoryRepository>{
  final String customerKey;

  GetHistoriesUseCase({required this.customerKey});
  @override
  Stream call(HistoryRepository repository) {
   return repository.getHistories(customerKey: customerKey);
  }


}