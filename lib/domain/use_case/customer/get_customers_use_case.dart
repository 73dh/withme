import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/repository/policy_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';
import '../base/base_use_case.dart';
import '../customer_use_case.dart';

class GetCustomersUseCase extends BaseUseCase<CustomerRepository> {
  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customers =
        await getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).first;
    final List<CustomerModel> policyCustomers = [];
    for (final customer in customers) {
      final policies = await getIt<PolicyRepository>().getPolicies(
        customerKey: customer.customerKey,
      );
      if (policies.isNotEmpty) {
        policyCustomers.add(customer);
      }
    }
    return policyCustomers;
  }

  // Stream<List<CustomerModel>> call(CustomerRepository repository) async* {
  //   Stream<List<CustomerModel>> getAll =
  //       getIt<CustomerUseCase>().call(usecase: GetAllUseCase())
  //         ;
  //
  //   await for (final customers in getAll) {
  //     List<CustomerModel> policyCustomers = [];
  //     for (var i = 0; i < customers.length; i++) {
  //       final policies = await getIt<PolicyRepository>().getPolicies(
  //         customerKey: customers[i].customerKey,
  //       );
  //       if (policies.isNotEmpty) {
  //         policyCustomers.add(customers[i]);
  //       }
  //     }
  //     yield policyCustomers;
  //   }
  // }
}
