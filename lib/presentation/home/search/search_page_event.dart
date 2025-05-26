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

  factory SearchPageEvent.selectProductCategory({
    required String productCategory,
  }) = SelectProductCategory;

  factory SearchPageEvent.selectInsuranceCompany({
    required String insuranceCompany,
  }) = SelectInsuranceCompany;

  factory SearchPageEvent.filterPolicy({String? productCategory,String? insuranceCompany})=FilterPolicy;
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

class SelectProductCategory implements SearchPageEvent {
  final String productCategory;

  SelectProductCategory({required this.productCategory});
}

class SelectInsuranceCompany implements SearchPageEvent {
  final String insuranceCompany;

  SelectInsuranceCompany({required this.insuranceCompany});
}

class FilterPolicy implements SearchPageEvent{
  final String? productCategory;
  final String? insuranceCompany;

  FilterPolicy({ this.productCategory,  this.insuranceCompany});
}