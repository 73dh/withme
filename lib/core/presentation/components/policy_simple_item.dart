import '../../../domain/model/policy_model.dart';
import '../../domain/enum/policy_state.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../core_presentation_import.dart';

class PolicySimpleItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicySimpleItem({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final notKeepPolicyState =
        policy.policyState == PolicyState.cancelled.label ||
        policy.policyState == PolicyState.lapsed.label;

    // 보험료 텍스트 스타일
    final premiumStyle =
        notKeepPolicyState
            ? textTheme.labelLarge?.copyWith(
              color: colorScheme.error,
              decoration: TextDecoration.lineThrough,
            )
            : textTheme.labelLarge?.copyWith(color: colorScheme.onSurface);

    // 상태 배경 색상
    final stateBgColor =
        notKeepPolicyState
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.tertiaryContainer.withValues(alpha: 0.2);

    // 상태 텍스트 색상
    final stateTextColor =
        notKeepPolicyState
            ? colorScheme.error
            : colorScheme.onTertiaryContainer;

    return ItemContainer(
      height: 120,
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 여기 변경
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '계약자: ${shortenedNameText(policy.policyHolder)}',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    '피보험자: ${shortenedNameText(policy.insured)}',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            height(4),
            Text(
              '상품명: ${policy.productName}',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            height(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '보험료: ',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${numFormatter.format(int.parse(policy.premium.replaceAll(',', '')))}원',
                          style: premiumStyle,
                        ),
                        TextSpan(
                          text: ' (${policy.paymentMethod})',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stateBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    policy.policyState,
                    style: textTheme.labelSmall?.copyWith(
                      color: stateTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
