import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';

class GetCustomersUseCase extends BaseStreamUseCase<CustomerRepository> {
  @override
  Stream call(CustomerRepository repository) async* {
    Stream<List<CustomerModel>> getAll = getIt<GetAllUseCase>().call(
      repository,
    );
    await for (final customers in getAll) {
      List<CustomerModel> policyCustomers = [];
      for (var i = 0; i < customers.length; i++) {
        final policies = await getIt<CustomerRepository>().getPolicies(
          customerKey: customers[i].customerKey,
        );
        if (policies.isNotEmpty) {
          policyCustomers.add(customers[i]);
        }
      }
      yield policyCustomers;
    }
  }
}
