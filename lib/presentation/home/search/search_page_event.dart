sealed class SearchPageEvent{
  factory SearchPageEvent.filterNoRecentHistoryCustomers({required int month})=FilterNoRecentHistoryCustomers;
  factory SearchPageEvent.filterCustomersByComingBirth()=FilterCustomersByComingBirth;
  factory SearchPageEvent.filterCustomersByUpcomingInsuranceAgeIncrease()=FilterCustomersByUpcomingInsuranceAgeIncrease;
  factory SearchPageEvent.filterNoBirthCustomers()=FilterNoBirthCustomers;
}

class FilterNoRecentHistoryCustomers implements SearchPageEvent{
  final int month;

  FilterNoRecentHistoryCustomers({required this.month});
}
class FilterCustomersByComingBirth implements SearchPageEvent{}
class FilterCustomersByUpcomingInsuranceAgeIncrease implements SearchPageEvent{}
class FilterNoBirthCustomers implements SearchPageEvent{}