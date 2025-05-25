import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/use_case/customer/get_all_data_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer/get_prospect_use_case.dart';
import 'package:withme/presentation/home/dash_board/dash_board_state.dart';

import '../../../core/di/setup.dart';

class DashBoardViewModel with ChangeNotifier {
  DashBoardViewModel() {
    getIt<CustomerUseCase>()
        .execute(usecase: GetAllDataUseCase())
        .then((customersAllData) {
          _state = state.copyWith(
            customers: customersAllData,
            histories:
                (customersAllData as List<CustomerModel>)
                    .expand((e) => e.histories)
                    .toList(),
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

  Map<String, List<CustomerModel>> groupCustomersByMonth(List<CustomerModel> customers) {
    final result = <String, List<CustomerModel>>{};

    for (var customer in customers) {
      final date = customer.registeredDate;
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      result.putIfAbsent(monthKey, () => []);
      result[monthKey]!.add(customer);
    }

    return result;
  }
}
