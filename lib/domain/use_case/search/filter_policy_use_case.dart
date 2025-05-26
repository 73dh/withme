import '../../model/customer_model.dart';
import '../../model/policy_model.dart';

class FilterPolicyUseCase {
  static Future<List<PolicyModel>> call({
    String? productCategory,
    String? insuranceCompany,
    required List<PolicyModel> policies,
  }) async {
    final filtered =
        policies.where((policy) {
          final matchesProduct =
              productCategory == null ||
              policy.productCategory == productCategory;
          final matchesCompany =
              insuranceCompany == null ||
              policy.insuranceCompany == insuranceCompany;
          return matchesProduct && matchesCompany;
        }).toList();

    print(
      'Filtered policies with productCategory:$productCategory, insuranceCompany:$insuranceCompany → ${filtered.length} results',
    );

    return filtered;
  }
}
