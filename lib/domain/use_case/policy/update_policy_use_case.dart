import '../../../core/di/di_setup_import.dart';
import '../../model/policy_model.dart';
import '../base/base_use_case.dart';

class UpdatePolicyUseCase extends BaseUseCase<PolicyRepository> {
  final String customerKey;
  final PolicyModel policy;

  UpdatePolicyUseCase({required this.customerKey, required this.policy});

  @override
  Future call(PolicyRepository repository) async {
    return await repository.updatePolicy(
      customerKey: customerKey,
      policy: policy,
    );
  }
}
