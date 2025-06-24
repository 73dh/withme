import '../../../core/di/di_setup_import.dart';
import '../../../core/di/setup.dart';
import '../../../core/domain/enum/policy_state.dart';
import '../../../core/presentation/components/common_policy_state_dialog.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../core/ui/core_ui_import.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../../core/utils/extension/number_format.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/use_case/policy/change_policy_state_use_case.dart';

class PolicyPart extends StatelessWidget {
  final PolicyModel policy;
  final CustomerModel customer;

  const PolicyPart({
    super.key,
    required this.policy,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return PartBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('계약자: ${shortenedNameText(policy.policyHolder, length: 5)}'),
                Row(
                  children: [
                    Text('피보험자: ${shortenedNameText(policy.insured, length: 5)}'),
                    sexIcon(policy.insuredSex),
                    width(10),
                    policy.insuredBirth != null
                        ? Text('${policy.insuredBirth!.formattedDate} (${calculateAge(policy.insuredBirth!)}세)')
                        : const Text('피보험자 생년월일 정보 없음'),
                  ],
                ),
              ],
            ),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('계약일: ${policy.startDate?.formattedDate}'),
                Text('만기일: ${policy.endDate?.formattedDate}'),
              ],
            ),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보험사: ${policy.insuranceCompany}'),
                Text('상품종류: ${policy.productCategory}'),
              ],
            ),
            height(5),
            Text('상품명: ${policy.productName}'),
            const DashedDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '보험료: ${numFormatter.format(int.parse(policy.premium.replaceAll(',', '')))} (${policy.paymentMethod})',
                  style: _isCancelledOrLapsed(policy.policyState) ? TextStyles.cancelStyle : null,
                ),
                GestureDetector(
                  onTap: () => _showPolicyStatePopup(context, policy),
                  child: Text(
                    policy.policyState,
                    style: _isCancelledOrLapsed(policy.policyState) ? TextStyles.cancelStyle : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isCancelledOrLapsed(String state) =>
      state == PolicyState.cancelled.label || state == PolicyState.lapsed.label;

  void _showPolicyStatePopup(BuildContext context, PolicyModel policy) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonPolicyStateDialog(
          policy: policy,
          onConfirm: (newState) async {
            await getIt<PolicyUseCase>().execute(
              usecase: ChangePolicyStateUseCase(
                customerKey: customer.customerKey,
                policyKey: policy.policyKey,
                policyState: newState,
              ),
            );
          },
        );
      },
    );
  }
}
