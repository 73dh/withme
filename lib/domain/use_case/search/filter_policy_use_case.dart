import '../../../core/domain/core_domain_import.dart';
import '../../../core/domain/enum/payment_status.dart';
import '../../../core/utils/check_payment_status.dart';
import '../../model/policy_model.dart';

class FilterPolicyUseCase {
  static Future<List<PolicyModel>> call({
    required String contractMonth,
    required ProductCategory productCategory,
    required InsuranceCompany insuranceCompany,
    required List<PolicyModel> policies,
    required PaymentStatus paymentStatus,
  }) async {
    final filtered =
        policies.where((policy) {
          final matchContractMonth =
              contractMonth == '전계약월' ||
              (policy.startDate != null &&
                  "${policy.startDate!.year}-${policy.startDate!.month.toString().padLeft(2, '0')}" ==
                      contractMonth);

          final matchProduct =
              policy.productCategory == productCategory.toString() ||
              productCategory == ProductCategory.all;

          final matchCompany =
              policy.insuranceCompany == insuranceCompany.toString() ||
              insuranceCompany == InsuranceCompany.all;

          // 납입 상태 필터
          final matchPaymentStatus = paymentStatus == PaymentStatus.all ||
              checkPaymentStatus(policy) == paymentStatus;

          return matchContractMonth && matchProduct && matchCompany&& matchPaymentStatus;
        }).toList();

    return filtered;
  }
}
