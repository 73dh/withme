import '../../repository/policy_repository.dart';
import '../base/base_use_case.dart';

class DeletePolicyUseCase extends BaseUseCase<PolicyRepository> {
  final String customerKey;
  final String policyKey;

  DeletePolicyUseCase({required this.customerKey, required this.policyKey});

  @override
  Future call(PolicyRepository repository) async {
    return await repository.deletePolicy(
      customerKey: customerKey,
      policyKey: policyKey,
    );
  }
}
