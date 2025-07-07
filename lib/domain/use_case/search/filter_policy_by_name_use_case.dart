import '../../model/policy_model.dart';

class FilterPolicyByNameUseCase {
  static List<PolicyModel> call({
    required List<PolicyModel> policies,
    required String keyword,
  }) {
    final lowerKeyword = keyword.toLowerCase();
    return policies.where((policy) {
      final policyHolderName = policy.policyHolder.toLowerCase() ;
      final insuredName = policy.insured.toLowerCase();
      return policyHolderName.contains(lowerKeyword) ||
          insuredName.contains(lowerKeyword);
    }).toList();
  }
}
