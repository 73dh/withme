import '../../../domain/model/policy_model.dart';
import '../../domain/enum/policy_state.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../core_presentation_import.dart';
class PolicyItem extends StatelessWidget {
  final PolicyModel policy;

  const PolicyItem({super.key, required this.policy});

  bool get isCancelled => policy.policyState == PolicyState.cancelled.label;

  bool get isLapsed => policy.policyState == PolicyState.lapsed.label;

  Color statusColor(ColorScheme colorScheme) {
    if (isLapsed) return colorScheme.error; // 기존 Colors.red
    if (isCancelled) return colorScheme.tertiary; // 기존 Colors.orange
    return colorScheme.onSurface; // 기존 Colors.black87
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            _personInfoRow(context, colorScheme),
            const DashedDivider(),
            _insuranceInfoRow(context, colorScheme),
            height(4),
            Text(
              '상품명: ${policy.productName}',
              style: Theme.of(context).textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
            const DashedDivider(),
            _contractDateRow(context, colorScheme),
            const DashedDivider(),
            _premiumAndStateRow(colorScheme),
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

  Widget _personInfoRow(BuildContext context, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _personDetail(
        context,
        sexIcon: sexIcon(policy.policyHolderSex, colorScheme),
        name: shortenedNameText(policy.policyHolder, length: 5),
        age: calculateAge(policy.policyHolderBirth!),
        birth: policy.policyHolderBirth?.formattedBirth ?? '-',
        colorScheme: colorScheme,
      ),
      _personDetail(
        context,
        sexIcon: sexIcon(policy.insuredSex, colorScheme),
        name: shortenedNameText(policy.insured, length: 5),
        age: calculateAge(policy.insuredBirth!),
        birth: policy.insuredBirth?.formattedBirth ?? '-',
        colorScheme: colorScheme,
      ),
    ],
  );

  Widget _insuranceInfoRow(BuildContext context, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(context, '보험사', policy.insuranceCompany, colorScheme: colorScheme),
      _labelValue(context, '종류', policy.productCategory, colorScheme: colorScheme),
    ],
  );

  Widget _contractDateRow(BuildContext context, ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _labelValue(context, '계약일', policy.startDate?.formattedBirth ?? '-', colorScheme: colorScheme),
      _labelValue(context, '만기일', policy.endDate?.formattedBirth ?? '-', colorScheme: colorScheme),
    ],
  );

  Widget _premiumAndStateRow(ColorScheme colorScheme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Expanded(child: _premiumText(colorScheme)), _statusBadge(colorScheme)],
  );

  Widget _premiumText(ColorScheme colorScheme) {
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
              color: statusColor(colorScheme),
              fontWeight: FontWeight.w500,
              decoration:
              (isCancelled || isLapsed) ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          TextSpan(text: ' (${policy.paymentMethod})'),
        ],
      ),
    );
  }

  Widget _statusBadge(ColorScheme colorScheme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: statusColor(colorScheme).withOpacity(0.2),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      policy.policyState,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _labelValue(BuildContext context, String label, String value,
      {ColorScheme? colorScheme}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: colorScheme?.onSurfaceVariant ?? Colors.grey),
          ),
          if (value.isNotEmpty) ...[
            height(2),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ],
      );

  Widget _personDetail(
      BuildContext context, {
        required String name,
        required Widget sexIcon,
        required int age,
        required String birth,
        ColorScheme? colorScheme,
      }) =>
      Row(
        children: [
          sexIcon,
          width(4),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          width(6),
          Text('$birth ($age세)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme?.onSurfaceVariant,
              )),
        ],
      );
}
