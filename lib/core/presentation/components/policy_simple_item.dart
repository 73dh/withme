import 'package:withme/core/presentation/components/birthday_badge.dart';
import 'package:withme/core/presentation/components/payment_status_icon.dart';

import '../../../domain/model/policy_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../ui/icon/const.dart';
import '../../utils/check_payment_status.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../../utils/policy_status_helper.dart';
import '../../utils/remaining_payment_period.dart';
import '../core_presentation_import.dart';

class PolicySimpleItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicySimpleItem({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final remainingMonths = monthsUntilEnd(policy);
    final showMaturityIcon =
        policy.paymentMethod == '월납' &&
        remainingMonths <= UserSession().remainPaymentMonth;

    // 상태 계산
    final status = checkPaymentStatus(policy);


    // 보험료 텍스트 스타일
    final premiumStyle = PolicyStatusHelper.premiumTextStyle(
      policy,
      textTheme,
      colorScheme,
    );
    // 상태 배경 색상
    final stateBgColor = PolicyStatusHelper.statusBackgroundColor(
      policy,
      colorScheme,
    );

    // 상태 텍스트 색상
    final stateTextColor = PolicyStatusHelper.statusTextColor(
      policy,
      colorScheme,
    );
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
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SexIcon(
                        sex: policy.policyHolderSex,
                        backgroundImagePath:
                            policy.policyHolderSex == '남'
                                ? IconsPath.manIcon
                                : IconsPath.womanIcon,
                        size: 20,
                      ),
                      width(5),
                      Text(
                        '계약자: ${shortenedNameText(policy.policyHolder)}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      width(3),
                      BirthdayBadge(
                        birth: policy.policyHolderBirth,
                        iconSize: 14,
                        textSize: 14,
                      ),
                      PaymentStatusIcon(status: status, size: 14), // ✅ 상태별 아이콘 자동 처리
                    ],
                  ),
                ),
                width(8), // 약간의 간격
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SexIcon(
                        sex: policy.insuredSex,
                        backgroundImagePath:
                            policy.insuredSex == '남'
                                ? IconsPath.manIcon
                                : IconsPath.womanIcon,
                        size: 20,
                      ),
                      width(5),
                      Text(
                        '피보험자: ${shortenedNameText(policy.insured)}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      width(3),
                      BirthdayBadge(
                        birth: policy.insuredBirth,
                        iconSize: 14,
                        textSize: 14,
                      ),
                    ],
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
                        // 납입방법
                        TextSpan(
                          text: ' (${policy.paymentMethod}',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // 납입기간 (월납일 때만 표시)
                        if (policy.paymentMethod == '월납')
                          TextSpan(
                            text: ', ${policy.paymentPeriod}년',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        TextSpan(
                          text: ')',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text:
                              policy.paymentMethod == '월납'
                                  ? calculateRemainingPaymentMonth(policy)
                                  : '',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                policy.startDate != null &&
                                        monthsUntilEnd(policy) <
                                            UserSession().remainPaymentMonth // 3개월 미만 체크
                                    ? colorScheme
                                        .error // 빨간색 등 강조
                                    : colorScheme.onSurfaceVariant,
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
