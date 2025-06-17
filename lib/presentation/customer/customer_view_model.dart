import 'package:flutter/material.dart';

import '../../core/di/setup.dart';
import '../../domain/model/history_model.dart';
import '../../domain/use_case/history/get_histories_use_case.dart';
import '../../domain/use_case/history_use_case.dart';

class CustomerViewModel with ChangeNotifier {
  Stream<List<HistoryModel>> getHistories(String userKey, String customerKey) {
    return getIt<HistoryUseCase>().call(
      usecase: GetHistoriesUseCase(userKey: userKey, customerKey: customerKey),
    );
  }
}
