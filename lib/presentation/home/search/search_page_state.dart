import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../../domain/model/history_model.dart';

class SearchPageState {
  final List<CustomerModel> customers;
  final List<HistoryModel> histories;
  final List<PolicyModel> policies;
  final List<CustomerModel> searchedCustomers;

  SearchPageState({
    this.customers = const [],
    this.histories = const [],
    this.policies = const [],
    this.searchedCustomers = const [],
  });

  SearchPageState copyWith({
    List<CustomerModel>? customers,
    List<HistoryModel>? histories,
    List<PolicyModel>? policies,
    List<CustomerModel>? searchedCustomers,
  }) {
    return SearchPageState(
      customers: customers ?? this.customers,
      histories: histories ?? this.histories,
      policies: policies ?? this.policies,
      searchedCustomers: searchedCustomers?? this.searchedCustomers,
    );
  }
}
