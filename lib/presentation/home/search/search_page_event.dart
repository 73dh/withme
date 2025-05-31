import 'package:withme/core/domain/enum/insurance_company.dart';
import 'package:withme/core/domain/enum/product_category.dart';
import 'package:withme/presentation/home/search/enum/no_contact_month.dart';

import 'enum/coming_birth.dart';
import 'enum/upcoming_insurance_age.dart';

sealed class SearchPageEvent {
  factory SearchPageEvent.filterNoRecentHistoryCustomers({
    required NoContactMonth month,
  }) = FilterNoRecentHistoryCustomers;

  factory SearchPageEvent.filterComingBirth({required ComingBirth birthDay}) =
      FilterComingBirth;

  factory SearchPageEvent.filterUpcomingInsuranceAge({
    required UpcomingInsuranceAge insuranceAge,
  }) = FilterUpcomingInsuranceAge;

  factory SearchPageEvent.filterNoBirthCustomers() = FilterNoBirthCustomers;

  factory SearchPageEvent.selectContractMonth({
    required String selectedContractMonth,
  }) = SelectContractMonth;

  factory SearchPageEvent.selectProductCategory({
    required ProductCategory productCategory,
  }) = SelectProductCategory;

  factory SearchPageEvent.selectInsuranceCompany({
    required InsuranceCompany insuranceCompany,
  }) = SelectInsuranceCompany;

  factory SearchPageEvent.filterPolicy({
    required ProductCategory productCategory,
    required InsuranceCompany insuranceCompany,
    required String selectedContractMonth,
  }) = FilterPolicy;
}

class FilterNoRecentHistoryCustomers implements SearchPageEvent {
  final NoContactMonth month;

  FilterNoRecentHistoryCustomers({required this.month});
}

class FilterComingBirth implements SearchPageEvent {
  final ComingBirth birthDay;

  FilterComingBirth({required this.birthDay});
}

class FilterUpcomingInsuranceAge implements SearchPageEvent {
  final UpcomingInsuranceAge insuranceAge;

  FilterUpcomingInsuranceAge({required this.insuranceAge});
}

class FilterNoBirthCustomers implements SearchPageEvent {}

class SelectContractMonth implements SearchPageEvent {
  final String selectedContractMonth;

  SelectContractMonth({required this.selectedContractMonth});
}

class SelectProductCategory implements SearchPageEvent {
  final ProductCategory productCategory;

  SelectProductCategory({required this.productCategory});
}

class SelectInsuranceCompany implements SearchPageEvent {
  final InsuranceCompany insuranceCompany;

  SelectInsuranceCompany({required this.insuranceCompany});
}

class FilterPolicy implements SearchPageEvent {
  final ProductCategory productCategory;
  final InsuranceCompany insuranceCompany;
  final String selectedContractMonth;

  FilterPolicy({
    required this.productCategory,
    required this.insuranceCompany,
    required this.selectedContractMonth,
  });
}
