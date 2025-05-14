import 'package:withme/domain/repository/history_repository.dart';
import 'package:withme/domain/repository/repository.dart';

import 'base/base_stream_use_case.dart';
import 'base/base_use_case.dart';

 class HistoryUseCase {
  final HistoryRepository _historyRepository;

  HistoryUseCase({required HistoryRepository historyRepository}) : _historyRepository = historyRepository;


  Future execute<T>({required BaseUseCase usecase}) async {
   return  usecase(_historyRepository);
  }

  Stream call<T>({required BaseStreamUseCase usecase}){
   return usecase(_historyRepository);
  }
 }