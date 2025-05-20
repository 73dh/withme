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

  void getAllData() {
    final historyFutures = <Future<List<HistoryModel>>>[];
    final policyFutures = <Future<List<PolicyModel>>>[];

    getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).listen((
        customerData ,
        ) async {

      _state = state.copyWith(customers: customerData);
      notifyListeners();

      for (var customer in customerData as List<CustomerModel>) {
        final historyFuture = getIt<HistoryUseCase>().call(
          usecase: GetHistoriesUseCase(customerKey: customer.customerKey),
        ).first;

        final policyFuture = getIt<PolicyUseCase>().call(
          usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
        ).first;

        // Future 객체 자체를 리스트에 추가
        historyFutures.add(historyFuture as Future<List<HistoryModel>>);
        policyFutures.add(policyFuture as Future<List<PolicyModel>>);
      }

      // 모든 Future 결과를 기다림
      final historiesList = await Future.wait(historyFutures);
      final policiesList = await Future.wait(policyFutures);

      // 결과들을 평탄화
      final allHistories = historiesList.expand((h) => h).toList();
      final allPolicies = policiesList.expand((p) => p).toList();

      _state = state.copyWith(histories: allHistories, policies: allPolicies);
      notifyListeners();

      log('customer length: ${state.customers.length}');
      log('history length: ${state.histories.length}');
      log('policies length: ${state.policies.length}');
    });
  }

  void isThisMonthBirth() {
    final now = DateTime.now();
    final searchedCustomers = state.customers.where((e) {
      if (e.birth == null) return false;

      final birth = e.birth!;
      // 생일의 연도를 현재로 바꾸어서 비교
      final thisYearsBirthday = DateTime(now.year, birth.month, birth.day);

      return thisYearsBirthday.month == now.month &&
          !thisYearsBirthday.isBefore(now);
    }).toList();

    print(searchedCustomers);
    _state = state.copyWith(searchedCustomers: searchedCustomers);
    notifyListeners();
  }

  void filterCustomersByUpcomingInsuranceAgeIncrease() {
    final now = DateTime.now();
    final in10Days = now.add(Duration(days: 10));
    final in30Days = now.add(Duration(days: 30));

    final filtered = state.customers.where((customer) {
      final birth = customer.birth;
      if (birth == null) return false;

      // 보험 상령일 = 생일 + 6개월
      final insuranceAgeIncreaseDate = DateTime(
        birth.year,
        birth.month + 6,
        birth.day,
      );

      // 올해 또는 내년의 보험 상령일 구하기
      DateTime thisYearIncrease = DateTime(
        now.year,
        insuranceAgeIncreaseDate.month,
        insuranceAgeIncreaseDate.day,
      );

      if (thisYearIncrease.isBefore(now)) {
        // 이미 지난 경우는 내년 상령일 사용
        thisYearIncrease = DateTime(
          now.year + 1,
          insuranceAgeIncreaseDate.month,
          insuranceAgeIncreaseDate.day,
        );
      }

      // 상령일이 10일 이상, 30일 이내인지 확인
      return thisYearIncrease.isAfter(in10Days) &&
          !thisYearIncrease.isAfter(in30Days);
    }).toList();

    _state = state.copyWith(searchedCustomers: filtered);
    notifyListeners();
  }

}
