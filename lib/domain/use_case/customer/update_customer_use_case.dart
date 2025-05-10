import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

class UpdateCustomerUseCase  extends BaseUseCase<CustomerRepository>{
  final String userKey;
  final Map<String, dynamic> customerData;

  UpdateCustomerUseCase({required this.userKey, required this.customerData});
  @override
  Future call(CustomerRepository repository) async {
    return await repository.updateCustomer(
      userKey: userKey,
      customerData: customerData,
    );
  }
}
