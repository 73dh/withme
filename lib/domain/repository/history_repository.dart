import 'package:withme/domain/repository/repository.dart';

import '../model/history_model.dart';

abstract interface class HistoryRepository implements Repository{
  Stream<List<HistoryModel>> getHistories({required String customerKey});

  Future<void> addHistory({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> historyData,
  });
}