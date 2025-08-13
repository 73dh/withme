import '../../../domain/model/policy_model.dart';
import '../../domain/enum/policy_state.dart';
import '../../ui/text_style/text_styles.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../core_presentation_import.dart';

class PolicyItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicyItem({super.key, required this.policy});

  bool get isCancelled => policy.policyState == PolicyState.cancelled.label;

  bool get isLapsed => policy.policyState == PolicyState.lapsed.label;

  Color get statusColor {
    if (isLapsed) return Colors.red;
    if (isCancelled) return Colors.orange;
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _titleRow(context),
            height(3),
            _personInfoRow(context),
            const DashedDivider(),
            _insuranceInfoRow(context),
            height(4),
            Text(
              '상품명: ${policy.productName}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
            const DashedDivider(),
            _contractDateRow(context),
            const DashedDivider(),
            _premiumAndStateRow(),
          ],
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(context, '계약자', ''),
      _labelValue(context, '피보험자', ''),
    ],
  );

  Widget _personInfoRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _personDetail(
        context,
        sexIcon: sexIcon(policy.policyHolderSex),
        name: shortenedNameText(policy.policyHolder, length: 5),
        age: calculateAge(policy.policyHolderBirth!),
        birth: policy.policyHolderBirth?.formattedBirth ?? '-',
      ),
      _personDetail(
        context,
        sexIcon: sexIcon(policy.insuredSex),
        name: shortenedNameText(policy.insured, length: 5),
        age: calculateAge(policy.insuredBirth!),
        birth: policy.insuredBirth?.formattedBirth ?? '-',
      ),
    ],
  );

  Widget _insuranceInfoRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(context, '보험사', policy.insuranceCompany),
      _labelValue(context, '종류', policy.productCategory),
    ],
  );

  Widget _contractDateRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(context, '계약일', policy.startDate?.formattedBirth ?? '-'),
      _labelValue(context, '만기일', policy.endDate?.formattedBirth ?? '-'),
    ],
  );

  Widget _premiumAndStateRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Expanded(child: _premiumText()), _statusBadge()],
  );

  Widget _premiumText() {
    final formattedPremium = numFormatter.format(
      int.parse(policy.premium.replaceAll(',', '')),
    );

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: '보험료: '),
          TextSpan(
            text: '$formattedPremium원',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
              decoration:
                  (isCancelled || isLapsed)
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
            ),
          ),
          TextSpan(text: ' (${policy.paymentMethod})'),
        ],
      ),
    );
  }

  Widget _statusBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      policy.policyState,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _labelValue(BuildContext context, String label, String value) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey),
          ),
          if (value.isNotEmpty) ...[
            height(2),
            Text(value, style:Theme.of(
              context,
            ).textTheme.headlineMedium),
          ],
        ],
      );

  Widget _personDetail(
    BuildContext context, {
    required String name,
    required Widget sexIcon,
    required int age,
    required String birth,
  }) => Row(
    children: [
      sexIcon,
      width(4),
      Text(name, style: Theme.of(
        context,
      ).textTheme.headlineMedium),
      width(6),
      Text('$birth ($age세)', style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
