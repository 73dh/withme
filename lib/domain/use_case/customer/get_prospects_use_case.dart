import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/repository/policy_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/presentation/home/dash_board/model/customer_data_model.dart';

import '../../../core/di/setup.dart';
import '../base/base_use_case.dart';

class GetProspectsUseCase extends BaseUseCase<CustomerRepository> {
  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customers =
        await getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).first;
    final List<CustomerModel> prospectCustomers = [];

    for (final customer in customers) {
      final policies = await getIt<PolicyRepository>().getPolicies(
        customerKey: customer.customerKey,
      );
      if (policies.isEmpty) {
        prospectCustomers.add(customer);
      }
    }

    return prospectCustomers;
  }
}
