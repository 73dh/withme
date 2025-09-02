import 'package:withme/core/presentation/components/birthday_badge.dart';
import 'package:withme/core/presentation/components/payment_status_icon.dart';

import '../../../domain/model/policy_model.dart';
import '../../data/fire_base/user_session.dart';
import '../../domain/enum/policy_state.dart';
import '../../ui/core_ui_import.dart';
import '../../utils/check_payment_status.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../../utils/policy_status_helper.dart';
import '../../utils/remaining_payment_period.dart';
import '../core_presentation_import.dart';

class PolicyItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicyItem({super.key, required this.policy});

  bool get isCancelled => policy.policyState == PolicyStatus.cancelled.label;

  bool get isLapsed => policy.policyState == PolicyStatus.lapsed.label;

  /// 상태별 컬러 반환
  Color statusColor(ColorScheme colorScheme) {
    if (isLapsed) return colorScheme.error;
    if (isCancelled) return colorScheme.tertiary;
    return colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ItemContainer(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _titleRow(textTheme, colorScheme),
            _personInfoRow(textTheme, colorScheme),
            const DashedDivider(),
            _insuranceInfoRow(textTheme, colorScheme),
            const DashedDivider(),
            Text(
              '상품명: ${policy.productName}',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const DashedDivider(),
            _contractDateRow(textTheme, colorScheme),
            const DashedDivider(),
            _premiumAndStateRow(textTheme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _titleRow(TextTheme textTheme, ColorScheme colorScheme) {
    // 상태 계산
    final status = checkPaymentStatus(policy);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _labelValue('계약자', '', textTheme, colorScheme),
            width(5),
            PaymentStatusIcon(status: status, size: 14),
            // ✅ 상태별 아이콘 자동 처리  ],
          ],
        ),
        _labelValue('피보험자', '', textTheme, colorScheme),
      ],
    );
  }

  Widget _personInfoRow(TextTheme textTheme, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _personDetail(
        textTheme,
        sexIcon: SexIcon(
          sex: policy.policyHolderSex,
          backgroundImagePath:
              policy.policyHolderSex == '남'
                  ? IconsPath.manIcon
                  : IconsPath.womanIcon,
          size: 20,
        ),
        name: shortenedNameText(policy.policyHolder, length: 5),
        age: calculateAge(policy.policyHolderBirth!),
        birth: policy.policyHolderBirth,
        colorScheme: colorScheme,
      ),
      _personDetail(
        textTheme,
        sexIcon: SexIcon(
          sex: policy.insuredSex,
          backgroundImagePath:
              policy.insuredSex == '남'
                  ? IconsPath.manIcon
                  : IconsPath.womanIcon,
          size: 20,
        ),
        name: shortenedNameText(policy.insured, length: 5),
        age: calculateAge(policy.insuredBirth!),
        birth: policy.insuredBirth,
        colorScheme: colorScheme,
      ),
    ],
  );

  Widget _insuranceInfoRow(TextTheme textTheme, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue('보험사', policy.insuranceCompany, textTheme, colorScheme),
      _labelValue('종류', policy.productCategory, textTheme, colorScheme),
    ],
  );

  Widget _contractDateRow(TextTheme textTheme, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(
        '계약일',
        policy.startDate?.formattedBirth ?? '-',
        textTheme,
        colorScheme,
      ),
      _labelValue(
        '만기일',
        policy.endDate?.formattedBirth ?? '-',
        textTheme,
        colorScheme,
      ),
    ],
  );

  Widget _premiumAndStateRow(TextTheme textTheme, ColorScheme colorScheme) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _premiumText(textTheme, colorScheme)),
          _statusBadge(textTheme, colorScheme),
        ],
      );

  Widget _premiumText(TextTheme textTheme, ColorScheme colorScheme) {
    final formattedPremium = numFormatter.format(
      int.parse(policy.premium.replaceAll(',', '')),
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '보험료: ',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: '$formattedPremium원',
            style: textTheme.labelMedium?.copyWith(
              color: statusColor(colorScheme),
              fontWeight: FontWeight.w600,
              decoration: (isCancelled || isLapsed)
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: statusColor(colorScheme), // ✅ 줄 색상 고정
              decorationThickness: 2, // ✅ 줄 두께
            ),
          ),
          // 납입방법
          TextSpan(
            text: ' (${policy.paymentMethod}',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
            text: policy.paymentMethod == '월납'
                ? calculateRemainingPaymentMonth(policy)
                : '',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: policy.startDate != null &&
                  monthsUntilEnd(policy) < UserSession().remainPaymentMonth
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  _statusBadge(TextTheme textTheme, ColorScheme colorScheme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: PolicyStatusHelper.statusBackgroundColor(policy, colorScheme),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      policy.policyState,
      style: textTheme.labelMedium?.copyWith(
        color: PolicyStatusHelper.statusTextColor(policy, colorScheme),
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _labelValue(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      if (value.isNotEmpty) ...[
        height(2),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    ],
  );

  Widget _personDetail(
    TextTheme textTheme, {
    required String name,
    required Widget sexIcon,
    required int age,
    required DateTime? birth, // <-- nullable DateTime으로
    required ColorScheme colorScheme,
  }) => Row(
    children: [
      sexIcon,
      width(4),
      Text(
        name,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      width(3),
      BirthdayBadge(birth: birth, iconSize: 10, textSize: 10),
      width(3),
      Text(
        '${birth?.formattedBirth ?? '-'} ($age세)', // 여기서 변환
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
