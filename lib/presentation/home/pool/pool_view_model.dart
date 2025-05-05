import 'package:flutter/material.dart';
import 'package:withme/presentation/home/pool/pool_state.dart';

import '../../../domain/use_case/get_pool_use_case.dart';

class PoolViewModel with ChangeNotifier {
  PoolState _state = PoolState();

  PoolState get state => _state;

  Future<void> getCustomers() async {
    final customers = await GetPoolUseCase.execute();
    _state = state.copyWith(initCustomers: customers);
    notifyListeners();
  }


}
