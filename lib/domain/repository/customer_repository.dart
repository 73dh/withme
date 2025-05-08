
import 'package:withme/domain/repository/repository.dart';

import '../model/customer_model.dart';
import '../model/history_model.dart';

abstract interface class CustomerRepository implements Repository{
  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  });

  Stream<List<CustomerModel>> getPools();

  Stream<List<HistoryModel>> fetchHistories({required String customerKey});

  Future<void> addHistory(HistoryModel history);
}
