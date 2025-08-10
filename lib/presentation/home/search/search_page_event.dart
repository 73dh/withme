import '../../../core/domain/core_domain_import.dart';
import '../home_grand_import.dart';

sealed class SearchPageEvent {
  factory SearchPageEvent.filterNoRecentHistoryCustomers({
    required NoContactMonth month,
  }) = FilterNoRecentHistoryCustomers;

  factory SearchPageEvent.filterComingBirth({required ComingBirth birthDay}) =
      FilterComingBirth;

  factory SearchPageEvent.filterUpcomingInsuranceAge({
    required UpcomingInsuranceAge insuranceAge,
  }) = FilterUpcomingInsuranceAge;

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
