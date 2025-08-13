import '../../../domain/model/policy_model.dart';
import '../../domain/enum/policy_state.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../core_presentation_import.dart';

class PolicySimpleItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicySimpleItem({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    final notKeepPolicyState =
        policy.policyState == PolicyState.cancelled.label ||
        policy.policyState == PolicyState.lapsed.label;
    return ItemContainer(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '계약자: ${shortenedNameText(policy.policyHolder)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '피보험자: ${shortenedNameText(policy.insured)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            height(4),
            Text(
              '상품명: ${policy.productName}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            /// 보험료 & 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: '보험료: '),
                        TextSpan(
                          text:
                              '${numFormatter.format(int.parse(policy.premium.replaceAll(',', '')))}원',
                          style:
                              notKeepPolicyState
                                  ? Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith( color: Colors.red,decoration: TextDecoration.lineThrough,)
                                  : null,
                        ),
                        TextSpan(text: ' (${policy.paymentMethod})'),
                      ],
                      // style: TextStyles.bold16, // 기본 스타일 (없으면 null)
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        notKeepPolicyState
                            ? Colors.red.withOpacity(0.3)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(policy.policyState),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
