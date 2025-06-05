import 'package:withme/domain/repository/history_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../model/history_model.dart';

class GetHistoriesUseCase
    extends BaseStreamUseCase<List<HistoryModel>, HistoryRepository> {
  final String customerKey;

  GetHistoriesUseCase({required this.customerKey});

  @override
  Stream<List<HistoryModel>> call(HistoryRepository repository) {
    return repository.getHistories(customerKey: customerKey);
  }
}
