

import '../../../core/domain/core_domain_import.dart';
import '../../model/policy_model.dart';

class FilterPolicyUseCase {
  static Future<List<PolicyModel>> call({
    required ProductCategory productCategory,
    required InsuranceCompany insuranceCompany,
    required List<PolicyModel> policies,
  }) async {
    final filtered =
        policies.where((policy) {
          final matchProduct =
              policy.productCategory == productCategory.toString() ||
              productCategory == ProductCategory.all;

          final matchCompany =
              policy.insuranceCompany == insuranceCompany.toString() ||
              insuranceCompany == InsuranceCompany.all;
          return matchProduct && matchCompany;
        }).toList();

    return filtered;
  }
}
