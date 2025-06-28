import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/repository/customer_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';
import '../history/get_histories_use_case.dart';
import '../policy/get_policies_use_case.dart';

class GetEditedAllUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;

  GetEditedAllUseCase({required this.userKey});

  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customerRepository = getIt<CustomerRepository>();
    final historyUseCase = getIt<HistoryUseCase>();
    final policyUseCase = getIt<PolicyUseCase>();

    // Step 1: 수정된 고객 데이터 가져오기
    final editedCustomers = await customerRepository.getEditedAll(
      userKey: userKey,
    );

    // Step 2: 각 고객에 대해 history와 policy를 병렬로 불러오기
    final futures = editedCustomers.map((customer) async {
      final histories =
          await historyUseCase
              .call(
                usecase: GetHistoriesUseCase(
                  userKey: userKey,
                  customerKey: customer.customerKey,
                ),
              )
              .first;

      final policies =
          await policyUseCase
              .call(
                usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
              )
              .first;

      return customer.copyWith(histories: histories, policies: policies);
    });

    // Step 3: 병렬 처리된 고객 목록 반환
    return await Future.wait(futures);
  }
}
