import 'dart:async';

import 'package:withme/data/data_source/remote/fbase.dart';
import 'package:withme/domain/model/customer.dart';
import 'package:withme/domain/repository/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FBase fBase;

  CustomerRepositoryImpl({required this.fBase});

  @override
  Future<List<Customer>> getCustomers() async {
    final rawCustomers = await fBase.getCustomers();

    return rawCustomers.map((customer) => Customer.fromJson(customer)).toList();
  }

  @override
  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async {
    await fBase.registerCustomer(
      userKey: userKey,
      customerData: customerData,
    );
  }
}
