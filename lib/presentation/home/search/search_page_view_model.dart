import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/history/get_customer_histories_use_case.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/presentation/home/search/search_page_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';

class SearchPageViewModel with ChangeNotifier {
  SearchPageState _state = SearchPageState();

  SearchPageState get state => _state;

  void getAllData() {
    List<HistoryModel> histories = [];
    List<PolicyModel> policies = [];
    getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).listen((
      customerData,
    ) {
      _state = state.copyWith(customers: customerData);

      for (var customer in customerData as List<CustomerModel>) {
        final historyData =
            getIt<HistoryUseCase>()
                .call(
                  usecase: GetHistoriesUseCase(
                    customerKey: customer.customerKey,
                  ),
                )
                .first;
        historyData.then((historyData) {
          histories.addAll(historyData);
          print('histories: $historyData');
        });
        // .listen((historyData) {
        //   for (var history in historyData as List<HistoryModel>) {
        //
        //   }
        //   _state = state.copyWith(histories: histories);
        // });

        getIt<PolicyUseCase>()
            .call(
              usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
            )
            .listen((policyData) {
              for (var policy in policyData as List<PolicyModel>) {
                policies.add(policy);
              }
              _state = state.copyWith(policies: policies);
            });
      }

      // for (var customer in customerData) {
      // getIt<PolicyUseCase>()
      //     .call(
      //       usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
      //     )
      //     .listen((policyData) {
      //       for (var policy in policyData as List<PolicyModel>) {
      //         policies.add(policy);
      //       }
      //       _state = state.copyWith(policies: policies);
      //     });
      // }
      notifyListeners();
      log('customer length: ${state.customers.length.toString()}');
      log('history length: ${state.histories.length.toString()}');
      log('policies length: ${state.policies.length.toString()}');
    });
  }
}
