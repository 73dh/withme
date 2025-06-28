import 'package:withme/core/di/di_setup_import.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';
import '../base/base_use_case.dart';
import '../history/get_histories_use_case.dart';
import '../policy/get_policies_use_case.dart';

class GetAllDataUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;

  GetAllDataUseCase({required this.userKey});

  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customerRepository = getIt<CustomerRepository>();
    final historyUseCase = getIt<HistoryUseCase>();
    final policyUseCase = getIt<PolicyUseCase>();

    // Step 1: 모든 고객 데이터 가져오기
    final originalCustomers =
        await customerRepository.getAll(userKey: userKey).first;

    // Step 2: history 및 policy를 병렬로 요청
    final futures = originalCustomers.map((customer) async {
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
