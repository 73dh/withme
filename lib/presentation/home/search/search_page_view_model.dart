import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/domain/use_case/search/filter_coming_birth_use_case.dart';
import 'package:withme/domain/use_case/search/filter_no_recent_history_use_case.dart';
import 'package:withme/domain/use_case/search/filter_policy_use_case.dart';
import 'package:withme/domain/use_case/search/filter_upcoming_insurance_use_case.dart';
import 'package:withme/presentation/home/search/search_page_event.dart';
import 'package:withme/presentation/home/search/search_page_state.dart';

import '../../../core/data/fire_base/user_session.dart';
import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/use_case/search/filter_policy_by_name_use_case.dart';
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
        _selectContractMonth(
          selectedContractMonth: event.selectedContractMonth,
        );
    }
  }

  void resetSearchOption() {
    _state = SearchPageState(
      customers: _state.customers,
      policies: _state.policies,
      histories: _state.histories,
      contractMonths: _state.contractMonths,
      currentSearchOption: null,
    );
    notifyListeners();
  }

  Future<void> getAllData() async {
    final userKey = UserSession.userId;
    if (userKey.isEmpty) {
      debugPrint('[SearchPageViewModel] userKey is empty. Aborting data load.');
      return;
    }

    _state = state.copyWith(isLoadingAllData: true);
    notifyListeners();
    final stopwatch = Stopwatch()..start();

    final customersAllData = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: UserSession.userId),
    );
    final customers = List<CustomerModel>.from(customersAllData);

    // Step 1: 먼저 policies만 뽑음
    final policies = await compute(_extractPolicies, customers);

    // Step 2: 병렬 작업
    final results = await Future.wait([
      compute(_extractHistories, customers),
      compute(_extractContractMonths, customers),
      compute(_extractProductCategories, policies),
      compute(_extractInsuranceCompanies, policies),
    ]);

    _state = state.copyWith(
      customers: customers,
      policies: policies,
      histories: results[0] as List<HistoryModel>,
      contractMonths: results[1] as List<String>,
      productCategories: results[2] as List<String>,
      insuranceCompanies: results[3] as List<String>,
      isLoadingAllData: false,
    );

    notifyListeners();
    debugPrint(
      '[getAllData time: ${stopwatch.elapsedMilliseconds}ms]\n'
          'currentOption: ${state.currentSearchOption}',
    );
  }

  // Future<void> getAllData() async {
  //   final userKey = UserSession.userId;
  //   if (userKey.isEmpty) {
  //     debugPrint('[SearchPageViewModel] userKey is empty. Aborting data load.');
  //     return;
  //   }
  //   _state = state.copyWith(isLoadingAllData: true);
  //   notifyListeners();
  //   final stopwatch = Stopwatch()..start();
  //
  //   final customersAllData = await getIt<CustomerUseCase>().execute(
  //     usecase: GetAllDataUseCase(userKey: UserSession.userId),
  //   );
  //   final customers = List<CustomerModel>.from(customersAllData);
  //
  //   // 병렬 처리로 성능 개선
  //   final policiesFuture = compute<List<CustomerModel>, List<PolicyModel>>(
  //     _extractPolicies,
  //     customers,
  //   );
  //   final historiesFuture = compute<List<CustomerModel>, List<HistoryModel>>(
  //     _extractHistories,
  //     customers,
  //   );
  //   final contractMonthsFuture = compute<List<CustomerModel>, List<String>>(
  //     _extractContractMonths,
  //     customers,
  //   );
  //   final productCategoriesFuture = compute<List<PolicyModel>, List<String>>(_extractProductCategories, policies);
  //   final insuranceCompaniesFuture = compute<List<PolicyModel>, List<String>>(_extractInsuranceCompanies, customers);
  //
  //
  //   final results = await Future.wait([
  //     policiesFuture,
  //     historiesFuture,
  //     contractMonthsFuture,
  //     productCategoriesFuture,
  //     insuranceCompaniesFuture,
  //   ]);
  //
  //   _state = state.copyWith(
  //     customers: customers,
  //     policies: results[0] as List<PolicyModel>,
  //     histories: results[1] as List<HistoryModel>,
  //     contractMonths: results[2] as List<String>,
  //     productCategories: results[3] as List<String>,
  //     insuranceCompanies: results[4] as List<String>,
  //     isLoadingAllData: false,
  //   );
  //
  //   notifyListeners();
  //   debugPrint(
  //     '[getAllData take time(milliseconds]: ${stopwatch.elapsedMilliseconds}ms'
  //     '\ncurrentOption: ${state.currentSearchOption}',
  //   );
  // }

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

  void _selectContractMonth({required String selectedContractMonth}) {
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
    required InsuranceCompany insuranceCompany,
  }) async {
    final filtered = await FilterPolicyUseCase.call(
      contractMonth: state.selectedContractMonth,
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

  void filterPolicyByName(String keyword) {
    final filtered = FilterPolicyByNameUseCase.call(
      policies: state.policies,
      keyword: keyword,
    );

    _state = state.copyWith(
      filteredPolicies: filtered,
      currentSearchOption: SearchOption.filterPolicy,
    );
    notifyListeners();
  }

  void toggleNameSearch(bool enabled) {
    _state = state.copyWith(isSearchingByName: enabled);
    notifyListeners();
  }
}

// compute에 사용될 함수들
List<PolicyModel> _extractPolicies(List<CustomerModel> customers) =>
    customers.expand((e) => e.policies).toList();

List<HistoryModel> _extractHistories(List<CustomerModel> customers) =>
    customers.expand((e) => e.histories).toList();

List<String> _extractContractMonths(List<CustomerModel> customers) {
  final months =
      customers
          .expand((e) => e.policies)
          .map((policy) => policy.startDate)
          .whereType<DateTime>()
          .map(
            (date) => '${date.year}-${date.month.toString().padLeft(2, '0')}',
          )
          .toSet()
          .toList();
  months.sort();
  return months;


}

List<String> _extractProductCategories(List<PolicyModel> policies) {
  final categories = policies

      .map((policy) => policy.productCategory)
      .toSet()
      .toList();

  categories.sort((a, b) => a.toString().compareTo(b.toString()));
  return categories;
}

List<String> _extractInsuranceCompanies(List<PolicyModel> policies) {
  final companies = policies
      .map((policy) => policy.insuranceCompany)
      .toSet()
      .toList();

  companies.sort((a, b) => a.toString().compareTo(b.toString()));
  return companies;
}
