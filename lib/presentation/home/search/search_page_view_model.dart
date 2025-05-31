import 'dart:async';

import 'package:flutter/material.dart';
import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/domain/use_case/search/filter_coming_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_recent_history_use_case.dart';
import 'package:withme/domain/use_case/search/filter_policy_use_case.dart';
import 'package:withme/domain/use_case/search/filter_upcoming_insurance_use_case.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_state.dart';

import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import 'enum/coming_birth.dart';
import 'enum/no_contact_month.dart';
import 'enum/search_option.dart';
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
      case SelectProductCategory():
        _selectProductCategory(productCategory: event.productCategory);
      case SelectInsuranceCompany():
        _selectInsuranceCompany(insuranceCompany: event.insuranceCompany);
      case FilterPolicy():
        _filterPolicy(
          productCategory: event.productCategory,
          insuranceCompany: event.insuranceCompany,
        );
      case SelectContractMonth():
        _selectContractMonth(selectedContractMonth: event.selectedContractMonth);
    }
  }

  Future<void> getAllData() async {
    _state = state.copyWith(isLoadingAllData: true);
    notifyListeners();

    List<CustomerModel> customersAllData = await getIt<CustomerUseCase>()
        .execute(usecase: GetAllDataUseCase());
    _state = state.copyWith(
      customers: customersAllData,
      histories: customersAllData.expand((e) => e.histories).toList(),
      policies: customersAllData.expand((e) => e.policies).toList(),
      isLoadingAllData: false,
    );
    notifyListeners();
  }

  Future<void> _filterNoRecentHistoryCustomers({
    required NoContactMonth monthOption,
  }) async {
    final filtered = await FilterNoRecentHistoryUseCase.call(
      customers: state.customers,
      month: monthOption,
    );
    _state = state.copyWith(
      filteredCustomers: List.from(filtered),
      currentSearchOption: SearchOption.noRecentHistory,
      noContactMonth: monthOption,
    );
    notifyListeners();
  }

  Future<void> _filterComingBirth({required ComingBirth birthOption}) async {
    final result = await FilterComingBirthUseCase.call(state.customers);

    final filtered = result[birthOption] ?? [];

    _state = state.copyWith(
      filteredCustomers: List.from(filtered),
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
      filteredCustomers: List.from(filtered),
      currentSearchOption: SearchOption.upcomingInsuranceAge,
      upcomingInsuranceAge: insuranceAge,
    );
    notifyListeners();
  }

  Future<void> _filterNoBirthCustomers() async {
    final filtered = await FilterNoBirthUseCase.call(state.customers);
    _state = state.copyWith(
      filteredCustomers: List.from(filtered),
      currentSearchOption: SearchOption.noBirth,
    );
    notifyListeners();
  }

  void _selectContractMonth({required String selectedContractMonth}){
    _state = state.copyWith(selectedContractMonth: selectedContractMonth);
    notifyListeners();
  }

  void _selectProductCategory({required ProductCategory productCategory}) {
    _state = state.copyWith(productCategory: productCategory);
    notifyListeners();
  }

  void _selectInsuranceCompany({required InsuranceCompany insuranceCompany}) {
    _state = state.copyWith(insuranceCompany: insuranceCompany);
    notifyListeners();
  }

  void _filterPolicy({
   required ProductCategory productCategory,
  required  InsuranceCompany insuranceCompany,
  }) async {
    final filtered = await FilterPolicyUseCase.call(
      policies: state.policies,
      productCategory: productCategory,
      insuranceCompany: insuranceCompany,
    );
    _state = state.copyWith(
      filteredPolicies: filtered,
      currentSearchOption: SearchOption.filterPolicy,
    );
    notifyListeners();
  }
}
