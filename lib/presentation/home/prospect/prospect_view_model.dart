import 'package:flutter/material.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/history/add_history_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/domain/use_case/history_use_case.dart';
import 'package:withme/presentation/home/prospect/prospect_event.dart';

import '../../../core/di/setup.dart';
import '../../../domain/use_case/history/get_histories_use_case.dart';
import '../../../domain/use_case/customer/get_prospect_use_case.dart';

class ProspectViewModel with ChangeNotifier {

  Stream getProspects() {
    return getIt<CustomerUseCase>().call(usecase: GetProspectUseCase());
  }

  Stream fetchHistories(String customerKey) {
    return getIt<HistoryUseCase>().call(
      usecase: GetHistoriesUseCase(customerKey: customerKey),
    );
  }

  onEvent(ProspectEvent event) {
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
    return getIt<CustomerUseCase>().execute(
      usecase: AddHistoryUseCase(
        userKey: 'user1',
        customerKey: customerKey,
        historyData: historyData,
      ),
    );
  }
}
