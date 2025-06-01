import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../../domain/model/history_model.dart';

class DashBoardState {
  final List<CustomerModel> customers;
  final List<HistoryModel> histories;
  final List<PolicyModel> policies;
  final Map<String, Map<String, List<CustomerModel>>>? monthlyCustomers;

  DashBoardState({
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.monthlyCustomers=const {},
  });

  DashBoardState copyWith({
    List<CustomerModel>? customers,
    List<HistoryModel>? histories,
    List<PolicyModel>? policies,
    Map<String, Map<String, List<CustomerModel>>>? monthlyCustomers,
  }) {
    return DashBoardState(
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      monthlyCustomers: monthlyCustomers??this.monthlyCustomers,
    );
  }
}


class MonthlyCustomerStats {
  final String month;
  final int prospectCount;
  final int customerCount;
  final List<CustomerModel> customers;

  MonthlyCustomerStats({
    required this.month,
    required this.prospectCount,
    required this.customerCount,
    required this.customers,
  });
}

List<MonthlyCustomerStats> generateMonthlyStatsList(List<CustomerModel> customers) {
  final Map<String, List<CustomerModel>> grouped = {};

  for (var customer in customers) {
    final date = customer.registeredDate;
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(customer);
  }

  final statsList = grouped.entries.map((entry) {
    final month = entry.key;
    final customerList = entry.value;

    final prospectCount = customerList.where((c) => c.policies.isEmpty).length;
    final customerCount = customerList.where((c) => c.policies.isNotEmpty).length;

    return MonthlyCustomerStats(
      month: month,
      prospectCount: prospectCount,
      customerCount: customerCount,
      customers: customerList,
    );
  }).toList();

  // 월 기준 정렬
  statsList.sort((a, b) => a.month.compareTo(b.month));

  return statsList;
}