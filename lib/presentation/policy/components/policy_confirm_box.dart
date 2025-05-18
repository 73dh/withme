import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/data/fire_base/firestore_keys.dart';

import '../../../core/presentation/widget/confirm_box_text.dart';
import '../../../core/presentation/components/render_filled_button.dart';
import '../../../core/presentation/components/width_height.dart';
import '../../../core/ui/color/color_style.dart';
import '../../../core/ui/text_style/text_styles.dart';

class PolicyConfirmBox extends StatelessWidget {
  final Map<String, dynamic> policyMap;
  final void Function(bool) onChecked;

  const PolicyConfirmBox({
    super.key,
    required this.policyMap,
    required this.onChecked,
  });

  _toDateFormatted(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final policyHolderName = policyMap[keyPolicyHolder];
    final policyHolderSex = policyMap[keyPolicyHolderSex];
    final policyHolderBirth = _toDateFormatted(
      policyMap[keyPolicyHolderBirth],
    );
    final String insuredName = policyMap[keyInsured];
    final String insuredSex = policyMap[keyInsuredSex];
    final String insuredBirth = _toDateFormatted(policyMap[keyInsuredBirth]);
    final String productCategory = policyMap[keyProductCategory];
    final String insuranceCompany = policyMap[keyInsuranceCompany];
    final String productName = policyMap[keyProductName];
    final String premiumController = policyMap[keyPremium];
    final String paymentMethod = policyMap[keyPaymentMethod];
    final String startDate = _toDateFormatted(policyMap[keyStartDate]);
    final String endDate = _toDateFormatted(policyMap[keyEndDate]);

    return Column(
      children: [
        height(20),
        const Text('계약정보 확인', style: TextStyles.bold20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(10),
              ConfirmBoxText(
                text: '계약자: ',
                text2:
                    '$policyHolderName ($policyHolderSex) $policyHolderBirth',
              ),

              ConfirmBoxText(
                text: '피보험자: ',
                text2: '$insuredName ($insuredSex) $insuredBirth',
              ),
              ConfirmBoxText(
                text: '상품종류: ',
                text2: '$productCategory ($insuranceCompany)',
              ),
              ConfirmBoxText(text: '상품명: ', text2: '$productName'),
              ConfirmBoxText(
                text: '보험료: ',
                text2: '$premiumController원 ($paymentMethod)',
              ),
              Row(
                children: [
                  ConfirmBoxText(text: '계약일: ', text2: '$startDate'),
                  width(10),
                  ConfirmBoxText(text: '만기일: ', text2: '$endDate'),
                ],
              ),
              height(20),
              RenderFilledButton(
                onPressed: () {
                  onChecked(true);
                  context.pop();
                  context.pop();
                },
                text: '계약 저장',
                borderRadius: 10,
                backgroundColor: ColorStyles.activeButtonColor,
                foregroundColor: Colors.black87,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
