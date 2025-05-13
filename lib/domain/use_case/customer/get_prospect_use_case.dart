import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';

import '../../../core/di/setup.dart';

class GetProspectUseCase extends BaseStreamUseCase<CustomerRepository> {
  @override
  Stream call(CustomerRepository repository) async* {
    Stream<List<CustomerModel>> getAll = getIt<GetAllUseCase>().call(
      repository,
    );
    await for (final customers in getAll) {
      List<CustomerModel> prospectCustomers = [];
      for (var i = 0; i < customers.length; i++) {
        final policies = await getIt<CustomerRepository>().getPolicies(
          customerKey: customers[i].customerKey,
        );
        if (policies.isEmpty) {
          prospectCustomers.add(customers[i]);
        }
      }
      yield prospectCustomers;
    }
  }
}
