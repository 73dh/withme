import '../model/customer.dart';

abstract interface class CustomerRepository{
  Future<void> registerCustomer({required String userKey,required Map<String,dynamic> customerData});
  Future<List<Customer>> getCustomers();
  // Stream<List<Customer>> getCustomers();
}