import '../../../domain/model/customer.dart';

class PoolState{
  final List<Customer> initCustomers;
  final List<Customer> sortedCustomers;

  PoolState({ this.initCustomers=const[],  this.sortedCustomers=const []});

  PoolState copyWith({
    List<Customer>? initCustomers,
    List<Customer>? sortedCustomers,
  }) {
    return PoolState(
      initCustomers: initCustomers ?? this.initCustomers,
      sortedCustomers: sortedCustomers ?? this.sortedCustomers,
    );
  }
}