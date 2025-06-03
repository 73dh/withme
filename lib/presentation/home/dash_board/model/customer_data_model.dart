import '../../../../domain/domain_import.dart';

class CustomerDataModel {
  final List<CustomerModel> total;
  final List<CustomerModel> prospect;
  final List<CustomerModel> contract;
  final Map<String, List<CustomerModel>> flattenedMonthly;

  CustomerDataModel({
    required this.total,
    required this.prospect,
    required this.contract,
    required this.flattenedMonthly,
  });
}

CustomerDataModel processCustomerData(
    List<CustomerModel> customers,
    Map<String, Map<String, List<CustomerModel>>>? monthlyCustomers,
    ) {
  final prospect = customers.where((c) => c.policies.isEmpty).toList();
  final contract = customers.where((c) => c.policies.isNotEmpty).toList();
  final total = [...prospect, ...contract];

  final Map<String, List<CustomerModel>> flattenedMonthly = {};
  monthlyCustomers?.forEach((month, typeMap) {
    final unique = <String, CustomerModel>{};
    for (final customers in typeMap.values) {
      for (final customer in customers) {
        unique[customer.customerKey] = customer;
      }
    }
    flattenedMonthly[month] = unique.values.toList();
  });

  return CustomerDataModel(
    total: total,
    prospect: prospect,
    contract: contract,
    flattenedMonthly: flattenedMonthly,
  );

}