import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

import '../../../domain/model/history_model.dart';
import 'enum/search_option.dart';

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
  final String? insuranceCompany;
  final String? productCategory;

  SearchPageState({
    this.isLoadingAllData=false,
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.filteredCustomers = const [],
    this.filteredPolicies=const [],
    this.currentSearchOption,
    this.noContactMonth = NoContactMonth.threeMonth,
    this.comingBirth = ComingBirth.today,
    this.upcomingInsuranceAge = UpcomingInsuranceAge.today,
    this.insuranceCompany,
    this.productCategory,
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
    String? insuranceCompany,
    String? productCategory,
  }) {
    return SearchPageState(
      isLoadingAllData: isLoadingAllData?? this.isLoadingAllData,
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      filteredPolicies: filteredPolicies?? this.filteredPolicies,
      currentSearchOption: currentSearchOption ?? this.currentSearchOption,
      noContactMonth: noContactMonth ?? this.noContactMonth,
      comingBirth: comingBirth ?? this.comingBirth,
      upcomingInsuranceAge: upcomingInsuranceAge ?? this.upcomingInsuranceAge,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      productCategory: productCategory ?? this.productCategory,
    );
  }
}
