
import '../model/customer_model.dart';
import '../model/history_model.dart';

abstract interface class CustomerRepository {
  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  });

  Stream<List<CustomerModel>> getPools();

  Stream<List<HistoryModel>> histories({required String customerKey});
}
