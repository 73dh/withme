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
import '../../../core/domain/enum/payment_status.dart';
import '../../../core/utils/check_payment_status.dart';
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

  /// 이벤트 처리
  Future<void> onEvent(SearchPageEvent event) async {
    if (event is FilterComingBirth) {
      await _filterComingBirth(birthOption: event.birthDay);
    } else if (event is FilterUpcomingInsuranceAge) {
      await _filterUpcomingInsuranceAge(insuranceAge: event.insuranceAge);
    } else if (event is FilterNoRecentHistoryCustomers) {
      await _filterNoRecentHistoryCustomers(monthOption: event.month);
    } else if (event is SelectProductCategory) {
      _selectProductCategory(productCategory: event.productCategory);
    } else if (event is SelectInsuranceCompany) {
      _selectInsuranceCompany(insuranceCompany: event.insuranceCompany);
    }
    else if (event is SelectPaymentStatus) {
      _selectPaymentStatus(paymentStatus: event.paymentStatus);
    }else if (event is FilterPolicy) {
      await _filterPolicy(
      );
    } else if (event is SelectContractMonth) {
      _selectContractMonth(selectedContractMonth: event.selectedContractMonth);
    }
  }

  /// 초기화
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

  /// 모든 데이터 가져오기
  Future<void> getAllData() async {
    final userKey = UserSession.userId;
    if (userKey.isEmpty) return;

    _state = state.copyWith(isLoadingAllData: true);
    notifyListeners();

    final stopwatch = Stopwatch()..start();

    final customersAllData = await getIt<CustomerUseCase>().execute(
      usecase: GetAllDataUseCase(userKey: userKey),
    );
    final customers = List<CustomerModel>.from(customersAllData);

    // policies만 뽑기
    final policies = await compute(_extractPolicies, customers);

    // 병렬 작업: histories, months, productCategories, insuranceCompanies
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

  /// 최근 연락 없는 고객 필터
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

  /// 다가오는 생일 필터
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

  /// 예정 보험 나이 필터
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

  /// 계약 월 선택
  void _selectContractMonth({required String selectedContractMonth}) {
    _state = state.copyWith(selectedContractMonth: selectedContractMonth);
    notifyListeners();
    _filterPolicy(); // ✅ 자동 필터 실행
  }

  /// 상품 카테고리 선택
  void _selectProductCategory({required ProductCategory productCategory}) {
    _state = state.copyWith(productCategory: productCategory);
    notifyListeners();
    _filterPolicy(); // ✅ 자동 필터 실행
  }

  /// 보험사 선택
  void _selectInsuranceCompany({required InsuranceCompany insuranceCompany}) {
    _state = state.copyWith(insuranceCompany: insuranceCompany);
    notifyListeners();
    _filterPolicy(); // ✅ 자동 필터 실행
  }

  /// 납입 상태
  void _selectPaymentStatus({ required PaymentStatus paymentStatus}) {


    _state = state.copyWith(paymentStatus: paymentStatus);
    notifyListeners();
    _filterPolicy(); // ✅ 자동 필터 실행
  }



  /// 정책 필터
  Future<void> _filterPolicy(
  ) async {
    final filtered = await FilterPolicyUseCase.call(
      contractMonth: state.selectedContractMonth,
      policies: state.policies,
      productCategory: state.productCategory,
      insuranceCompany:state.insuranceCompany,
      paymentStatus: state.paymentStatus,
    );
    _state = state.copyWith(
      filteredPolicies: filtered,
      currentSearchOption: SearchOption.filterPolicy,
    );
    notifyListeners();
  }
  /// 필터 초기화
  void resetFilters() {
    _state = _state.copyWith(
      productCategory: ProductCategory.all,
      insuranceCompany: InsuranceCompany.all,
      selectedContractMonth: '전계약월',
      paymentStatus: PaymentStatus.all,
    );
    _filterPolicy();
    notifyListeners();
  }

  /// 이름으로 정책 검색
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

// ================= compute helper =================
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
  final categories =
      policies
          .map((policy) => policy.productCategory.toString())
          .toSet()
          .toList();
  categories.sort();
  return categories;
}

List<String> _extractInsuranceCompanies(List<PolicyModel> policies) {
  final companies =
      policies
          .map((policy) => policy.insuranceCompany.toString())
          .toSet()
          .toList();
  companies.sort();
  return companies;
}
