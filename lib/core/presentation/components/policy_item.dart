import 'package:flutter/material.dart';
import '../../../domain/model/policy_model.dart';
import '../../ui/text_style/text_styles.dart';
import '../../utils/core_utils_import.dart';
import '../../utils/extension/number_format.dart';
import '../core_presentation_import.dart';

class PolicyItem extends StatelessWidget {
  final PolicyModel policy;
  const PolicyItem({super.key, required this.policy});

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
                Text(
                  '계약자: ${shortenedNameText(policy.policyHolder, length: 5)}',
                ),

                Row(
                  children: [
                    Text(
                      '피보험자: ${shortenedNameText(policy.insured, length: 5)}',
                    ),
                    sexIcon(policy.insuredSex),
                    width(10),
                    Text(
                      '${policy.insuredBirth?.formattedDate} (${calculateAge(policy.insuredBirth!)}세)',
                    ),
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
                  style:
                  policy.policyState == '해지'
                      ? TextStyles.cancelStyle
                      : null,
                ),
                Text(
                  policy.policyState,
                  style:
                  policy.policyState == '해지'
                      ? TextStyles.cancelStyle
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
