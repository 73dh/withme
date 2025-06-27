import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

class GetEditedAllUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;

  GetEditedAllUseCase({required this.userKey});

  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) {
    return repository.getEditedAll(userKey: userKey);
  }
}
