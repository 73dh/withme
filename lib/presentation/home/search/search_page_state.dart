import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../../domain/model/history_model.dart';
import '../home_grand_import.dart';

class SearchPageState {
  final bool isLoadingAllData;
  final List<CustomerModel> customers;
  final List<HistoryModel> histories;
  final List<PolicyModel> policies;
  final List<CustomerModel> filteredCustomers;
  final List<PolicyModel> filteredPolicies;
  final SearchOption? currentSearchOption;
  final NoContactMonth noContactMonth;
  final ComingBirth comingBirth;
  final UpcomingInsuranceAge upcomingInsuranceAge;
  final InsuranceCompany insuranceCompany;
  final ProductCategory productCategory;
  final List<String> contractMonths;
  // 추가
  final List<String> productCategories;
  final List<String> insuranceCompanies;
  final String selectedContractMonth;
  final bool isSearchingByName;

  SearchPageState({
    this.isLoadingAllData = false,
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.filteredCustomers = const [],
    this.filteredPolicies = const [],
    this.currentSearchOption,
    this.noContactMonth = NoContactMonth.threeMonth,
    this.comingBirth = ComingBirth.noBirthInfo,
    this.upcomingInsuranceAge = UpcomingInsuranceAge.today,
    this.insuranceCompany = InsuranceCompany.all,
    this.productCategory = ProductCategory.all,
    this.contractMonths = const [],
    this.productCategories = const [],
    this.insuranceCompanies = const [],
    this.selectedContractMonth = '전계약월',
    this.isSearchingByName = false,
  });

  SearchPageState copyWith({
    bool? isLoadingAllData,
    List<CustomerModel>? customers,
    List<HistoryModel>? histories,
    List<PolicyModel>? policies,
    List<CustomerModel>? filteredCustomers,
    List<PolicyModel>? filteredPolicies,
    SearchOption? currentSearchOption,
    NoContactMonth? noContactMonth,
    ComingBirth? comingBirth,
    UpcomingInsuranceAge? upcomingInsuranceAge,
    InsuranceCompany? insuranceCompany,
    ProductCategory? productCategory,
    List<String>? contractMonths,
    // 추가
    List<String>? productCategories,
    List<String>? insuranceCompanies,
    String? selectedContractMonth,
    bool? isSearchingByName,
  }) {
    return SearchPageState(
      isLoadingAllData: isLoadingAllData ?? this.isLoadingAllData,
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      filteredPolicies: filteredPolicies ?? this.filteredPolicies,
      currentSearchOption: currentSearchOption ?? this.currentSearchOption,
      noContactMonth: noContactMonth ?? this.noContactMonth,
      comingBirth: comingBirth ?? this.comingBirth,
      upcomingInsuranceAge: upcomingInsuranceAge ?? this.upcomingInsuranceAge,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      productCategory: productCategory ?? this.productCategory,
      contractMonths: contractMonths ?? this.contractMonths,
     // 추가
      productCategories: productCategories ?? this.productCategories,
      insuranceCompanies: insuranceCompanies ?? this.insuranceCompanies,
      selectedContractMonth:
          selectedContractMonth ?? this.selectedContractMonth,
      isSearchingByName: isSearchingByName ?? this.isSearchingByName,
    );
  }
}
