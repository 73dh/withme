import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/history/get_histories_use_case.dart';
import 'package:withme/domain/use_case/policy/get_policies_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_recent_history_use_case.dart';
import 'package:withme/domain/use_case/search/filter_coming_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_upcoming_insurance_use_case.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import 'enum/coming_birth.dart';
import 'enum/search_option.dart';
import 'enum/no_contact_month.dart';
import 'enum/upcoming_insurance_age.dart';

class SearchPageViewModel with ChangeNotifier {
  SearchPageState _state = SearchPageState();

  SearchPageState get state => _state;

  onEvent(SearchPageEvent event) {
    switch (event) {
      case FilterComingBirth():
        _filterComingBirth(birthOption: event.birthDay);
      case FilterUpcomingInsuranceAge():
        _filterUpcomingInsuranceAge(insuranceAge: event.insuranceAge);
      case FilterNoRecentHistoryCustomers():
        _filterNoRecentHistoryCustomers(monthOption: event.month);
      case FilterNoBirthCustomers():
        _filterNoBirthCustomers();
    }
  }

  Future<void> getAllData() async {
    final historyFutures = <Future<List<HistoryModel>>>[];
    final policyFutures = <Future<List<PolicyModel>>>[];

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
        notifyListeners();
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
    });
  }

  Future<void> _filterNoRecentHistoryCustomers({
    required NoContactMonth monthOption,
  }) async {
    final filtered = await FilterNoRecentHistoryUseCase.call(
      customers: state.customers,
      month: monthOption,
    );
    _state = state.copyWith(
      searchedCustomers: List.from(filtered),
      currentSearchOption: SearchOption.noRecentHistory,
      noContactMonth: monthOption,
    );
    notifyListeners();
  }

  Future<void> _filterComingBirth({required ComingBirth birthOption}) async {
    final result = await FilterComingBirthUseCase.call(state.customers);

    final filtered = result[birthOption] ?? [];

    _state = state.copyWith(
      searchedCustomers: List.from(filtered),
      currentSearchOption: SearchOption.comingBirth,
      comingBirth: birthOption,
    );
    notifyListeners();
  }

  Future<void> _filterUpcomingInsuranceAge({
    required UpcomingInsuranceAge insuranceAge,
  }) async {
    final result = await FilterUpcomingInsuranceUseCase.call(state.customers);
    final filtered = result[insuranceAge] ?? [];

    _state = state.copyWith(
      searchedCustomers: List.from(filtered),
      currentSearchOption: SearchOption.upcomingInsuranceAge,
      upcomingInsuranceAge: insuranceAge
    );
    notifyListeners();
  }

  Future<void> _filterNoBirthCustomers() async {
    final filtered = await FilterNoBirthUseCase.call(state.customers);
    _state = state.copyWith(
      searchedCustomers: List.from(filtered),
      currentSearchOption: SearchOption.noBirth,
    );
    notifyListeners();
  }
}
