import 'package:withme/domain/repository/history_repository.dart';

import 'base/base_stream_use_case.dart';
import 'base/base_use_case.dart';

class HistoryUseCase {
  final HistoryRepository _historyRepository;

  HistoryUseCase({required HistoryRepository historyRepository})
    : _historyRepository = historyRepository;

  Future execute<T>({required BaseUseCase usecase}) async {
    return usecase(_historyRepository);
  }

  Stream<R> call<R>({required BaseStreamUseCase<R,HistoryRepository> usecase}) {
    return usecase(_historyRepository);
  }
}
