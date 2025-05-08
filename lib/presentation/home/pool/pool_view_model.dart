import 'package:flutter/material.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/presentation/home/pool/pool_event.dart';

import '../../../core/di/setup.dart';
import '../../../domain/use_case/customer/fetch_histories_use_case.dart';
import '../../../domain/use_case/customer/get_pool_use_case.dart';

class PoolViewModel with ChangeNotifier {
  Stream getPools() {
    return getIt<CustomerUseCase>().call(usecase: GetPoolUseCase());
  }

  Stream fetchHistories(String customerKey) {
    return getIt<CustomerUseCase>().call(
      usecase: FetchHistoriesUseCase(customerKey: customerKey),
    );
  }

  onEvent(PoolEvent event) {
switch(event){

  case AddHistory():
   _addHistory(event.history);
}
  }

Future _addHistory(HistoryModel history)async{

}
}
