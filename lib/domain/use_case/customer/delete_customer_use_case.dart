import '../../../core/di/di_setup_import.dart';
import '../base/base_use_case.dart';

class DeleteCustomerUseCase implements BaseUseCase<CustomerRepository> {
  final String userKey;
  final String customerKey;

  DeleteCustomerUseCase({required this.userKey, required this.customerKey});

  @override
  Future call(CustomerRepository repository) async {
    return await repository.deleteCustomer(userKey: userKey, customerKey: customerKey);
  }
}
