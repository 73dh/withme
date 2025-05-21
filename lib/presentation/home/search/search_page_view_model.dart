import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_recent_history_use_case.dart';
import 'package:withme/domain/use_case/search/filter_this_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_upcoming_insurance_use_case.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';

class SearchPageViewModel with ChangeNotifier {
  SearchPageState _state = SearchPageState();

  SearchPageState get state => _state;

onEvent(SearchPageEvent event){
  switch(event){

    case FilterCustomersByComingBirth():
      _filterCustomersByComingBirth();
    case FilterCustomersByUpcomingInsuranceAgeIncrease():
      _filterCustomersByUpcomingInsuranceAgeIncrease();
    case FilterNoRecentHistoryCustomers():
      _filterNoRecentHistoryCustomers();
  }
}

  void getAllData() {
    final historyFutures = <Future<List<HistoryModel>>>[];
    final policyFutures = <Future<List<PolicyModel>>>[];

    if (state.customers.isNotEmpty) return;

    getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).listen((
      originalCustomers,
    ) async {
      for (var customer in originalCustomers as List<CustomerModel>) {
        final historyFuture =
            getIt<HistoryUseCase>()
                .call(
                  usecase: GetHistoriesUseCase(
                    customerKey: customer.customerKey,
                  ),
                )
                .first;

        final policyFuture =
            getIt<PolicyUseCase>()
                .call(
                  usecase: GetPoliciesUseCase(
                    customerKey: customer.customerKey,
                  ),
                )
                .first;

        // Future 객체 자체를 리스트에 추가
        historyFutures.add(historyFuture as Future<List<HistoryModel>>);
        policyFutures.add(policyFuture as Future<List<PolicyModel>>);
      }

      // 모든 Future 결과를 기다림
      final historiesList = await Future.wait(historyFutures);
      final policiesList = await Future.wait(policyFutures);

      // 각 customer에 해당하는 history, policy 붙이기
      final updatedCustomers = List.generate(originalCustomers.length, (i) {
        final updated = originalCustomers[i].copyWith(
          histories: historiesList[i],
          policies: policiesList[i],
        );
        return updated;
      });

      // 결과들을 평탄화 하여 저장
      _state = state.copyWith(
        customers: updatedCustomers,
        histories: historiesList.expand((e) => e).toList(),
        policies: policiesList.expand((e) => e).toList(),
      );
      notifyListeners();

      log('customer length: ${state.customers.length}');
      log('history length: ${state.histories.length}');
      log('policies length: ${state.policies.length}');
    });
  }

  Future<void> _filterCustomersByComingBirth() async {
    final filtered = await FilterThisBirthUseCase.call(state.customers);

    _state = state.copyWith(searchedCustomers: filtered);
    notifyListeners();
  }

  Future<void> _filterCustomersByUpcomingInsuranceAgeIncrease() async {
    final filtered = await FilterUpcomingInsuranceUseCase.call(state.customers);
    _state = state.copyWith(searchedCustomers: filtered);
    notifyListeners();
  }

  Future<void> _filterNoRecentHistoryCustomers() async {
    final filtered = await FilterNoRecentHistoryUseCase.call(state.customers);

    _state = state.copyWith(searchedCustomers: filtered);
    notifyListeners();
  }
}
