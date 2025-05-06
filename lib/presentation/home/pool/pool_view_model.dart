import 'package:flutter/material.dart';
import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/repository/customer_repository.dart';

import '../../../core/di/setup.dart';
import '../../../domain/use_case/get_pool_use_case.dart';

class PoolViewModel with ChangeNotifier {




  Stream getPools(){
    return  getIt<GetPoolUseCase>().execute();
  }

  Stream getHistories(String customerKey) {
    return getIt<CustomerRepository>().histories(customerKey: customerKey);
  }
}
