import 'package:withme/domain/model/history_model.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../repository/policy_repository.dart';

class GetPoliciesUseCase
    extends BaseStreamUseCase<List<PolicyModel>, PolicyRepository> {
  final String customerKey;

  GetPoliciesUseCase({required this.customerKey});

  @override
  Stream<List<PolicyModel>> call(PolicyRepository repository) {
    return repository.fetchPolicies(customerKey: customerKey);
  }
}
