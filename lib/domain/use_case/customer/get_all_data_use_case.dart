import 'package:withme/core/di/di_setup_import.dart';

import '../../../core/di/setup.dart';
import '../../model/customer_model.dart';
import '../../model/history_model.dart';
import '../../model/policy_model.dart';
import '../../model/todo_model.dart';
import '../base/base_use_case.dart';
import '../history/get_histories_use_case.dart';
import '../policy/get_policies_use_case.dart';
import '../todo/get_todos_use_case.dart';
import '../todo_use_case.dart';
//
// class GetAllDataUseCase extends BaseUseCase<CustomerRepository> {
//   final String userKey;
//
//   GetAllDataUseCase({required this.userKey});
//
//   @override
//   Future<List<CustomerModel>> call(CustomerRepository repository) async {
//     final customerRepository = getIt<CustomerRepository>();
//     final historyUseCase = getIt<HistoryUseCase>();
//     final policyUseCase = getIt<PolicyUseCase>();
// final todoUseCase =getIt<TodoUseCase>();
//     // Step 1: 모든 고객 데이터 가져오기
//     final originalCustomers =
//         await customerRepository.getAll(userKey: userKey).first;
//
//     // Step 2: history 및 policy를 병렬로 요청
//     final futures = originalCustomers.map((customer) async {
//       final histories =
//           await historyUseCase
//               .call(
//                 usecase: GetHistoriesUseCase(
//                   userKey: userKey,
//                   customerKey: customer.customerKey,
//                 ),
//               )
//               .first;
//
//
//       final policies =
//           await policyUseCase
//               .call(
//                 usecase: GetPoliciesUseCase(customerKey: customer.customerKey),
//               )
//               .first;
//
//       return customer.copyWith(histories: histories, policies: policies);
//     });
//
//     // Step 3: 병렬 처리된 고객 목록 반환
//     return await Future.wait(futures);
//   }
// }
class GetAllDataUseCase extends BaseUseCase<CustomerRepository> {
  final String userKey;

  GetAllDataUseCase({required this.userKey});

  @override
  Future<List<CustomerModel>> call(CustomerRepository repository) async {
    final customerRepository = getIt<CustomerRepository>();
    final historyUseCase = getIt<HistoryUseCase>();
    final policyUseCase = getIt<PolicyUseCase>();
    final todoUseCase = getIt<TodoUseCase>(); // ✅ 추가

    // Step 1: 모든 고객 데이터 가져오기
    final originalCustomers =
    await customerRepository.getAll(userKey: userKey).first;

    // Step 2: 각 고객의 history, policy, todo 병렬 요청
    final futures = originalCustomers.map((customer) async {
      final historiesFuture = historyUseCase
          .call(
        usecase: GetHistoriesUseCase(
          userKey: userKey,
          customerKey: customer.customerKey,
        ),
      )
          .first;

      final policiesFuture = policyUseCase
          .call(
        usecase: GetPoliciesUseCase(
          customerKey: customer.customerKey,
        ),
      )
          .first;

      final todosFuture = todoUseCase
          .call(
        usecase: GetTodosUseCase(
          userKey: userKey,
          customerKey: customer.customerKey,
        ),
      )
          .first;

      // 병렬 실행
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

    // Step 3: 모든 고객 데이터 완료
    return await Future.wait(futures);
  }
}
