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
      // 월별 계약 고객 그룹 (startDate 기준)
      final Map<String, List<CustomerModel>> contractGrouped = {};

      // 월별 가망 고객 그룹 (registeredDate 기준, 계약 없는 고객)
      final Map<String, List<CustomerModel>> prospectGrouped = {};

      for (var customer in customersAllData as List<CustomerModel>) {
        // 가망 고객 (계약 없는 고객)
        if (customer.policies == null || customer.policies.isEmpty) {
          final regDate = customer.registeredDate;
          final regMonth = '${regDate.year}-${regDate.month.toString().padLeft(2, '0')}';

          prospectGrouped.putIfAbsent(regMonth, () => []);
          prospectGrouped[regMonth]!.add(customer);
          continue; // 계약 없으니 아래 계약 처리 건너뜀
        }

        // 계약 고객 - 계약별 startDate 기준
        for (var policy in customer.policies) {
          final startDate = policy.startDate;
          if (startDate == null) continue;

          final contractMonth = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';

          contractGrouped.putIfAbsent(contractMonth, () => []);
          contractGrouped[contractMonth]!.add(customer);
        }
      }

      // 여기서 월별로 둘 다 합쳐서 원하는 형태로 사용 가능
      // 예: 한 map에 month별로 { 'prospect': [...], 'contract': [...] } 형태

      final Map<String, Map<String, List<CustomerModel>>> monthlyGrouped = {};

      final allMonths = <String>{
        ...prospectGrouped.keys,
        ...contractGrouped.keys,
      }.toList()..sort();

      for (var month in allMonths) {
        monthlyGrouped[month] = {
          'prospect': prospectGrouped[month] ?? [],
          'contract': contractGrouped[month] ?? [],
        };
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

    // getIt<CustomerUseCase>()
    //     .execute(usecase: GetAllDataUseCase())
    //     .then((customersAllData) {
    //       // 월별 고객 분류용 맵 초기화
    //       final Map<String, List<CustomerModel>> monthlyGrouped = {};
    //
    //       for (var customer in customersAllData as List<CustomerModel>) {
    //         final date = customer.registeredDate;
    //         final monthKey =
    //             '${date.year}-${date.month.toString().padLeft(2, '0')}';
    //
    //         // 해당 월에 해당하는 리스트에 고객 추가
    //         monthlyGrouped.putIfAbsent(monthKey, () => []);
    //         monthlyGrouped[monthKey]!.add(customer);
    //       }
    //
    //       _state = state.copyWith(
    //         monthlyCustomers: monthlyGrouped,
    //         customers: customersAllData,
    //         histories: customersAllData.expand((e) => e.histories).toList(),
    //         policies: customersAllData.expand((e) => e.policies).toList(),
    //       );
    //
    //       notifyListeners();
    //     })
    //     .catchError((e, stack) {
    //       log(e.toString());
    //     });
  }

  DashBoardState _state = DashBoardState();

  DashBoardState get state => _state;
}
