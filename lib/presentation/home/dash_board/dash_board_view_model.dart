import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';

import 'package:withme/presentation/home/dash_board/dash_board_state.dart';

import '../../../core/di/setup.dart';

class DashBoardViewModel with ChangeNotifier {
  DashBoardViewModel() {
    getIt<CustomerUseCase>()
        .execute(usecase: GetAllDataUseCase())
        .then((customersAllData) {
          // 월별 고객 분류용 맵 초기화
          final Map<String, List<CustomerModel>> monthlyGrouped = {};

          for (var customer in customersAllData as List<CustomerModel>) {
            final date = customer.registeredDate;
            final monthKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}';

            // 해당 월에 해당하는 리스트에 고객 추가
            monthlyGrouped.putIfAbsent(monthKey, () => []);
            monthlyGrouped[monthKey]!.add(customer);
          }

          _state = state.copyWith(
            monthlyCustomers: monthlyGrouped,
            customers: customersAllData,
            histories: customersAllData.expand((e) => e.histories).toList(),
            policies: customersAllData.expand((e) => e.policies).toList(),
          );

          notifyListeners();
        })
        .catchError((e, stack) {
          log(e.toString());
        });
  }

  DashBoardState _state = DashBoardState();

  DashBoardState get state => _state;
}
