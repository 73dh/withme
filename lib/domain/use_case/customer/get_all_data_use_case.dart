import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';
import '../../model/history_model.dart';
import '../../model/policy_model.dart';
import '../base/base_use_case.dart';
import '../history/get_histories_use_case.dart';
import '../policy/get_policies_use_case.dart';
import 'get_all_use_case.dart';

class GetAllDataUseCase extends BaseUseCase<CustomerRepository> {
  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final originalCustomers =
        await getIt<CustomerUseCase>().call(usecase: GetAllUseCase()).first
            ;
    final historyFutures = <Future<List<HistoryModel>>>[];
    final policyFutures = <Future<List<PolicyModel>>>[];

    for (var customer in originalCustomers) {
      final historyFuture =
          getIt<HistoryUseCase>()
              .call(
                usecase: GetHistoriesUseCase(customerKey: customer.customerKey),
              )
              .first;

      final policyFuture =
          getIt<PolicyUseCase>()
              .call(
                usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
              )
              .first;

      // Future 객체 자체를 리스트에 추가
      historyFutures.add(historyFuture );
      policyFutures.add(policyFuture );
    }

    // 모든 Future 결과를 기다림
    final historiesList = await Future.wait(historyFutures);
    final policiesList = await Future.wait(policyFutures);

    // 각 customer에 해당하는 history, policy 붙이기
    final updatedCustomers = List.generate(originalCustomers.length, (i) {
      return originalCustomers[i].copyWith(
        histories: historiesList[i],
        policies: policiesList[i],
      );
    });
    return updatedCustomers;
  }
}
