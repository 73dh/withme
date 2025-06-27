import 'package:withme/domain/repository/repository.dart';

import '../model/customer_model.dart';

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

  Future<void> deleteCustomer({required String userKey, required String customerKey});

  Stream<List<CustomerModel>> getAll({required String userKey});

  // 추가후 stream 아닌 data에서 가져오기
  Future<List<CustomerModel>> getEditedAll({required String userKey}); // 👈 추가
}
