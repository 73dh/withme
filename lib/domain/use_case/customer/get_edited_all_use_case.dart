import 'package:withme/domain/model/customer_model.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';
import '../../model/history_model.dart';
import '../../model/policy_model.dart';
import '../../model/todo_model.dart';
import '../history/get_histories_use_case.dart';
import '../policy/get_policies_use_case.dart';
import '../todo/get_todos_use_case.dart';
import '../todo_use_case.dart'; // ✅ 추가

class GetEditedAllUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;

  GetEditedAllUseCase({required this.userKey});

  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customerRepository = getIt<CustomerRepository>();
    final historyUseCase = getIt<HistoryUseCase>();
    final policyUseCase = getIt<PolicyUseCase>();
    final todoUseCase = getIt<TodoUseCase>(); // ✅ 추가

    // Step 1: 수정된 고객 데이터 가져오기
    final editedCustomers = await customerRepository.getEditedAll(
      userKey: userKey,
    );

    // Step 2: 각 고객에 대해 history, policy, todo 병렬로 요청
    final futures = editedCustomers.map((customer) async {
      final historiesFuture =
          historyUseCase
              .call(
                usecase: GetHistoriesUseCase(
                  userKey: userKey,
                  customerKey: customer.customerKey,
                ),
              )
              .first;

      final policiesFuture =
          policyUseCase
              .call(
                usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
              )
              .first;

      final todosFuture =
          todoUseCase
              .call(
                usecase: GetTodosUseCase(
                  userKey: userKey,
                  customerKey: customer.customerKey,
                ),
              )
              .first;

      final results = await Future.wait([
        historiesFuture,
        policiesFuture,
        todosFuture,
      ]);

      return customer.copyWith(
        histories: results[0] as List<HistoryModel>,
        policies: results[1] as List<PolicyModel>,
        todos: results[2] as List<TodoModel>,
      );
    });

    // Step 3: 병렬 처리된 고객 목록 반환
    return await Future.wait(futures);
  }
}
