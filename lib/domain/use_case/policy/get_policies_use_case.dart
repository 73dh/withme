import 'package:withme/domain/use_case/base/base_stream_use_case.dart';

import '../../repository/policy_repository.dart';

class GetPoliciesUseCase implements BaseStreamUseCase<PolicyRepository> {
  final String customerKey;

  GetPoliciesUseCase({required this.customerKey});

  @override
  Stream call(PolicyRepository repository) {
    return repository.fetchPolicies(customerKey: customerKey);
  }
}
