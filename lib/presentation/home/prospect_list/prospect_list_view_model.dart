import 'package:flutter/material.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/domain/use_case/history_use_case.dart';
import 'package:withme/presentation/home/prospect_list/prospect_list_event.dart';

import '../../../core/di/setup.dart';
import '../../../domain/use_case/customer/get_prospect_use_case.dart';
import '../../../domain/use_case/history/get_histories_use_case.dart';

class ProspectListViewModel with ChangeNotifier {
  Stream getProspects() {
    return getIt<CustomerUseCase>().call(usecase: GetProspectUseCase());
  }

  Stream fetchHistories(String customerKey) {
    return getIt<HistoryUseCase>().call(
      usecase: GetHistoriesUseCase(customerKey: customerKey),
    );
  }

  onEvent(ProspectListEvent event) {
    switch (event) {
      case AddHistory():
        _addHistory(
          customerKey: event.customerKey,
          historyData: event.historyData,
        );
    }
  }

  Future _addHistory({
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) async {
    return getIt<HistoryUseCase>().execute(
      usecase: AddHistoryUseCase(
        userKey: 'user1',
        customerKey: customerKey,
        historyData: historyData,
      ),
    );
  }
}
