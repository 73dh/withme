import '../../repository/policy_repository.dart';
import '../base/base_use_case.dart';

class ChangePolicyStateUseCase extends BaseUseCase<PolicyRepository> {
  final String customerKey;
  final String policyKey;
  final String policyState;

  ChangePolicyStateUseCase({
    required this.customerKey,
    required this.policyKey,
    required this.policyState,
  });

  @override
  Future call(PolicyRepository repository) async {
    return await repository.changePolicyState(
      customerKey: customerKey,
      policyKey: policyKey,
      policyState: policyState,
    );
  }
}
