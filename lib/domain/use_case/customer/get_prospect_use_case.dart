import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/repository/policy_repository.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_use_case.dart';
import 'package:withme/domain/use_case/customer_use_case.dart';
import 'package:withme/presentation/home/dash_board/model/customer_data_model.dart';

import '../../../core/di/setup.dart';

class GetProspectUseCase
    extends BaseStreamUseCase<List<CustomerModel>, CustomerRepository> {
  @override
  // Stream<List<CustomerModel>> call(CustomerRepository repository) async* {
  //   Stream<List<CustomerModel>> getAll = getIt<CustomerUseCase>().call(
  //     usecase: GetAllUseCase(),
  //   );
  //   await for (final customers in getAll) {
  //     List<CustomerModel> prospectCustomers = [];
  //     for (var i = 0; i < customers.length; i++) {
  //       final policies = await getIt<PolicyRepository>().getPolicies(
  //         customerKey: customers[i].customerKey,
  //       );
  //       if (policies.isEmpty) {
  //         prospectCustomers.add(customers[i]);
  //       }
  //     }
  //     yield prospectCustomers;
  //   }
  // }
  Stream<List<CustomerModel>> call(CustomerRepository repository) async* {
    List<CustomerModel> prospectCustomers = [];
    try {
      final getAll = getIt<CustomerUseCase>().call(usecase: GetAllUseCase());
      await for (final customers in getAll) {
        for (final customer in customers) {
          final policies = await getIt<PolicyRepository>().getPolicies(
            customerKey: customer.customerKey,
          );
          if (policies.isEmpty) {
            prospectCustomers.add(customer);
          }
        }
        yield prospectCustomers;
        break;
      }
    } catch (e) {
      prospectCustomers.add(e as CustomerModel);
      yield prospectCustomers;
    }
  }
}
