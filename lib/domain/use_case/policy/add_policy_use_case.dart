import 'package:withme/domain/repository/policy_repository.dart';
import 'package:withme/domain/use_case/base/base_use_case.dart';

class AddPolicyUseCase extends BaseUseCase<PolicyRepository> {
  final String userKey;
  final String customerKey;
  final Map<String, dynamic> policyData;

  AddPolicyUseCase({
    required this.userKey,
    required this.customerKey,
    required this.policyData,
  });

  @override
  Future call(PolicyRepository repository) async {
    return await repository.addPolicy(
      userKey: userKey,
      customerKey: customerKey,
      policyData: policyData,
    );
  }
}
