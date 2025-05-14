import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/domain/repository/repository.dart';

import '../model/customer_model.dart';
import '../model/history_model.dart';

abstract interface class CustomerRepository implements Repository {
  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  });

  Future<void> updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  });

  Future<void> deleteCustomer({required String customerKey});

  Stream<List<CustomerModel>> getAll();

  // Stream<List<HistoryModel>> getHistories({required String customerKey});
  //
  // Future<void> addHistory({
  //   required String userKey,
  //   required String customerKey,
  //   required Map<String, dynamic> historyData,
  // });


}
