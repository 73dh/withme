import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

class RegisterCustomerUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;
  final Map<String, dynamic> customerData;
  final Map<String, dynamic> historyData;
  // final Map<String, dynamic> todoData;

  RegisterCustomerUseCase({
    required this.userKey,
    required this.customerData,
    required this.historyData,
    // required this.todoData,
  });

  @override
  Future call(CustomerRepository repository) async {
    return await repository.registerCustomer(
      userKey: userKey,
      customerData: customerData,
      historyData: historyData,
      // todoData: todoData,
    );
  }
}
