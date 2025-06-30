import 'package:flutter/material.dart';
import 'package:withme/core/presentation/widget/item_container.dart';
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
    return ItemContainer(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 계약자 & 피보험자 (타이틀만)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_labelValue('계약자', ''), _labelValue('피보험자', '')],
            ),
            height(3),

            /// 이름, 성별, 나이
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _personDetail(
                  name: shortenedNameText(policy.policyHolder, length: 5),
                  sexIcon: sexIcon(policy.policyHolderSex),
                  age: calculateAge(policy.policyHolderBirth!),
                  birth: policy.policyHolderBirth?.formattedDate ?? '-',
                ),
                _personDetail(
                  name: shortenedNameText(policy.insured, length: 5),
                  sexIcon: sexIcon(policy.insuredSex),
                  age: calculateAge(policy.insuredBirth!),
                  birth: policy.insuredBirth?.formattedDate ?? '-',
                ),
              ],
            ),
            // height(4),
            const DashedDivider(),



            /// 보험사 & 상품 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _labelValue('보험사', policy.insuranceCompany),
                _labelValue('종류', policy.productCategory),
              ],
            ),
            height(4),
            Text(
              '상품명: ${policy.productName}',
              style: TextStyles.subTitle,
              overflow: TextOverflow.ellipsis,
            ),
            // height(4),
            const DashedDivider(),
            /// 계약일 & 만기일
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _labelValue('계약일', policy.startDate?.formattedDate ?? '-'),
                _labelValue('만기일', policy.endDate?.formattedDate ?? '-'),
              ],
            ),
            // height(4),
            const DashedDivider(),

            /// 보험료 & 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '보험료: ${numFormatter.format(int.parse(policy.premium.replaceAll(',', '')))}원 (${policy.paymentMethod})',
                    style:
                        policy.policyState == '해지'
                            ? TextStyles.cancelStyle
                            : TextStyles.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        policy.policyState == '해지'
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    policy.policyState,
                    style:
                        policy.policyState == '해지'
                            ? TextStyles.cancelStyle
                            : TextStyles.caption.copyWith(
                              color: Colors.green[700],
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

  /// 라벨 + 값 묶음 위젯 (계약일, 만기일, 보험사 등)
  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.caption),
        if (value.isNotEmpty) ...[
          height(2),
          Text(value, style: TextStyles.bodyBold),
        ],
      ],
    );
  }

  /// 이름, 성별 아이콘, 나이 위젯 (한 줄)
  Widget _personDetail({
    required String name,
    required Widget sexIcon,
    required int age,
    required String birth,
  }) {
    return Row(
      children: [
        Text(name, style: TextStyles.bodyBold),
        width(4),
        sexIcon,
        width(6),
        Text('$birth ($age세)', style: TextStyles.caption),
      ],
    );
  }
}
