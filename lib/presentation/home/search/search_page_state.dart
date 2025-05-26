import 'package:withme/core/domain/enum/insurance_category.dart';
import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/presentation/home/search/enum/coming_birth.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';
import 'package:withme/presentation/home/search/enum/upcoming_insurance_age.dart';

import '../../../domain/model/history_model.dart';
import 'enum/search_option.dart';

class SearchPageState {
  final List<CustomerModel> customers;
  final List<HistoryModel> histories;
  final List<PolicyModel> policies;
  final List<CustomerModel> searchedCustomers;
  final SearchOption? currentSearchOption;
  final NoContactMonth noContactMonth;
  final ComingBirth comingBirth;
  final UpcomingInsuranceAge upcomingInsuranceAge;
  final InsuranceCompany? insuranceCompany;
  final InsuranceCategory? insuranceCategory;

  SearchPageState({
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.searchedCustomers = const [],
    this.currentSearchOption,
    this.noContactMonth = NoContactMonth.threeMonth,
    this.comingBirth = ComingBirth.today,
    this.upcomingInsuranceAge = UpcomingInsuranceAge.today,
    this.insuranceCompany,
    this.insuranceCategory,
  });

  SearchPageState copyWith({
    List<CustomerModel>? customers,
    List<HistoryModel>? histories,
    List<PolicyModel>? policies,
    List<CustomerModel>? searchedCustomers,
    SearchOption? currentSearchOption,
    NoContactMonth? noContactMonth,
    ComingBirth? comingBirth,
    UpcomingInsuranceAge? upcomingInsuranceAge,
    InsuranceCompany? insuranceCompany,
    InsuranceCategory? insuranceCategory,
  }) {
    return SearchPageState(
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      searchedCustomers: searchedCustomers ?? this.searchedCustomers,
      currentSearchOption: currentSearchOption ?? this.currentSearchOption,
      noContactMonth: noContactMonth ?? this.noContactMonth,
      comingBirth: comingBirth ?? this.comingBirth,
      upcomingInsuranceAge: upcomingInsuranceAge ?? this.upcomingInsuranceAge,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      insuranceCategory: insuranceCategory ?? this.insuranceCategory,
    );
  }
}
