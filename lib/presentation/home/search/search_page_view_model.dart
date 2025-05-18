import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
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

  void getAllData() async {
    final customerUseCase = getIt<CustomerUseCase>();
    final historyUseCase = getIt<HistoryUseCase>();
    final policyUseCase = getIt<PolicyUseCase>();

    final customersData = await customerUseCase.call(usecase: GetAllUseCase()).first;
    final customers = customersData.cast<CustomerModel>();

    _state = state.copyWith(customers: customers);
    notifyListeners();

    List<HistoryModel> allHistories = [];
    List<PolicyModel> allPolicies = [];

     final streams = customers.map((customer) async* {
       await for(var customer in customers){

      final historyStream = historyUseCase.call(
        usecase: GetHistoriesUseCase(customerKey: customer.customerKey),
      );
       }
      final policyStream = policyUseCase.call(
        usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
      );

      final historyData = await historyStream.first;
      final policyData = await policyStream.first;

      allHistories.addAll(historyData.cast<HistoryModel>());
      allPolicies.addAll(policyData.cast<PolicyModel>());
    });

    // yield Future.wait(futures);

    _state = state.copyWith(
      histories: allHistories,
      policies: allPolicies,
    );

    log('customer length: ${state.customers.length}');
    log('history length: ${state.histories.length}');
    log('policies length: ${state.policies.length}');

    notifyListeners();
  }


// void getAllData() {
  //   getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).listen((
  //     customerData,
  //   ) {
  //     _state = state.copyWith(customers: customerData);
  //
  //     for (var customer in customerData as List<CustomerModel>) {
  //       getIt<HistoryUseCase>()
  //           .call(
  //             usecase: GetHistoriesUseCase(customerKey: customer.customerKey),
  //           )
  //           .listen((historyData) {
  //             List<HistoryModel> histories = [];
  //             for (var history in historyData as List<HistoryModel>) {
  //               histories.add(history);
  //             }
  //             _state = state.copyWith(histories: histories);
  //           });
  //       getIt<PolicyUseCase>()
  //           .call(
  //             usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
  //           )
  //           .listen((policyData) {
  //             List<PolicyModel> policies = [];
  //             for (var policy in policyData as List<PolicyModel>) {
  //               policies.add(policy);
  //             }
  //             _state = state.copyWith(policies: policies);
  //           });
  //     }
  //     log('customer length: ${state.customers.length.toString()}');
  //     log('history length: ${state.histories.length.toString()}');
  //     log('policies length: ${state.policies.length.toString()}');
  //     notifyListeners();
  //   });
  // }
}
